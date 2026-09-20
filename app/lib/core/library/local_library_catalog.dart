import 'package:doxan/core/library/library_collections.dart';
import 'package:doxan/core/library/library_ids.dart';
import 'package:doxan/core/library/library_snapshot.dart';
import 'package:doxan/core/library/library_store.dart';
import 'package:doxan/core/library/library_writer.dart';
import 'package:doxan/core/logging/app_logger.dart';
import 'package:doxan/core/models/document_draft.dart';
import 'package:doxan/core/models/library_models.dart';
import 'package:doxan/core/models/remote_document_meta.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:doxan/core/models/saved_folder.dart';
import 'package:doxan/core/models/sync_status.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/core/storage/local_file_store.dart';
import 'package:doxan/core/sync/sync_queue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:doxan/core/library/library_store.dart' show catalogFile;

final libraryCatalogProvider =
    NotifierProvider<LocalLibraryCatalog, LibrarySnapshot>(
      LocalLibraryCatalog.new,
    );

final libraryWriterProvider = Provider<LibraryWriter>((ref) {
  return ref.read(libraryCatalogProvider.notifier);
});

final savedDocumentByIdProvider = Provider.family<SavedDocument?, String>((
  ref,
  id,
) {
  return ref.watch(libraryCatalogProvider).documentById(id);
});

class LocalLibraryCatalog extends Notifier<LibrarySnapshot>
    implements LibraryWriter {
  @override
  LibrarySnapshot build() {
    Future<void>.microtask(reload);
    return const LibrarySnapshot();
  }

  Future<void> reload() async {
    try {
      final files = ref.read(localFileStoreProvider);
      final loaded = await ref.read(libraryStoreProvider).load();
      var folders = loaded.folders;
      var documents = loaded.documents;

      if (folders.isEmpty) {
        folders = DefaultFolders.createDefaults();
      }

      final kept = <SavedDocument>[];
      for (final doc in documents) {
        if (LibraryCollections.shouldPurge(doc)) {
          await files.deleteDocumentDir(doc.id);
        } else {
          kept.add(doc);
        }
      }

      state = LibrarySnapshot(folders: folders, documents: kept);
      await _persist();
    } catch (error) {
      AppLogger.debug('Catalog hydrate skipped: $error');
      if (state.folders.isEmpty) {
        state = LibrarySnapshot(folders: DefaultFolders.createDefaults());
      }
    }
  }

  SavedDocument? byId(String id) => state.documentById(id);

  @override
  Future<SavedDocument> write(DocumentDraft draft) async {
    final store = ref.read(localFileStoreProvider);
    final pdfPath = await store.writeBytes(
      '${draft.id}/document.pdf',
      draft.pdfBytes,
    );
    final pages = draft.pageJpegs.isEmpty
        ? [draft.previewJpeg]
        : draft.pageJpegs;
    final pagePaths = <String>[];
    for (var i = 0; i < pages.length; i++) {
      pagePaths.add(
        await store.writeBytes('${draft.id}/page_$i.jpg', pages[i]),
      );
    }
    final previewPath = pagePaths.first;
    final folderName = LibraryCollections.folderDisplayName(
      folderId: draft.folderId,
      folders: state.folders,
    );
    final now = DateTime.now();
    final saved = SavedDocument(
      summary: DocumentSummary(
        id: draft.id,
        name: draft.name,
        format: 'PDF',
        sizeBytes: draft.pdfBytes.length,
        folderId: draft.folderId,
        folderName: folderName,
        updatedAt: now,
        ocrText: draft.ocrText,
        createdAt: now,
        syncStatus: _initialSyncStatus(),
      ),
      pdfPath: pdfPath,
      previewPath: previewPath,
      pageCount: draft.pageCount,
      pagePaths: pagePaths,
    );
    state = LibrarySnapshot(
      folders: state.folders,
      documents: [saved, ...state.documents.where((doc) => doc.id != saved.id)],
    );
    await _persist();
    await _enqueue(SyncJobType.upsertMetadata, saved.id);
    await _enqueue(SyncJobType.uploadBackup, saved.id);
    return saved;
  }

  Future<void> updateOcr(String id, String ocrText) async {
    await _updateDocument(
      id,
      (doc) => doc.copyWith(
        summary: doc.summary.copyWith(
          ocrText: ocrText,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> renameDocument(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _updateDocument(
      id,
      (doc) => doc.copyWith(
        summary: doc.summary.copyWith(
          name: trimmed,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> moveDocument(String id, String? folderId) async {
    final folderName = LibraryCollections.folderDisplayName(
      folderId: folderId,
      folders: state.folders,
    );
    await _updateDocument(
      id,
      (doc) => doc.copyWith(
        summary: doc.summary.copyWith(
          folderId: folderId,
          folderName: folderName,
          updatedAt: DateTime.now(),
          clearFolder: folderId == null,
        ),
      ),
    );
    if (folderId != null) {
      await _touchFolder(folderId);
    }
  }

  Future<void> toggleFavorite(String id) async {
    await _updateDocument(
      id,
      (doc) => doc.copyWith(
        summary: doc.summary.copyWith(
          isFavorite: !doc.summary.isFavorite,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> trashDocument(String id) async {
    await _updateDocument(
      id,
      (doc) => doc.copyWith(
        summary: doc.summary.copyWith(
          deletedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> restoreDocument(String id) async {
    await _updateDocument(
      id,
      (doc) => doc.copyWith(
        summary: doc.summary.copyWith(
          updatedAt: DateTime.now(),
          clearDeletedAt: true,
        ),
      ),
    );
  }

  Future<void> deleteDocumentPermanently(String id) async {
    final store = ref.read(localFileStoreProvider);
    await store.deleteDocumentDir(id);
    state = LibrarySnapshot(
      folders: state.folders,
      documents: state.documents.where((doc) => doc.id != id).toList(),
    );
    await _persist();
    await _enqueue(SyncJobType.deleteRemote, id);
  }

  Future<void> deleteAllDocuments() async {
    final store = ref.read(localFileStoreProvider);
    for (final doc in state.documents) {
      await store.deleteDocumentDir(doc.id);
      await _enqueue(SyncJobType.deleteRemote, doc.id);
    }
    state = LibrarySnapshot(folders: state.folders);
    await _persist();
  }

  Future<SavedFolder> createFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('empty_folder');
    }
    final folder = SavedFolder(
      id: LibraryIds.newId(),
      name: trimmed,
      updatedAt: DateTime.now(),
    );
    state = LibrarySnapshot(
      folders: [...state.folders, folder],
      documents: state.documents,
    );
    await _persist();
    await _enqueue(SyncJobType.upsertMetadata, folder.id);
    return folder;
  }

  Future<void> renameFolder(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final folders = [
      for (final folder in state.folders)
        if (folder.id == id)
          folder.copyWith(name: trimmed, updatedAt: DateTime.now())
        else
          folder,
    ];
    final documents = [
      for (final doc in state.documents)
        if (doc.summary.folderId == id)
          doc.copyWith(summary: doc.summary.copyWith(folderName: trimmed))
        else
          doc,
    ];
    state = LibrarySnapshot(folders: folders, documents: documents);
    await _persist();
    await _enqueue(SyncJobType.upsertMetadata, id);
  }

  Future<void> deleteFolder(String id) async {
    final documents = [
      for (final doc in state.documents)
        if (doc.summary.folderId == id)
          doc.copyWith(
            summary: doc.summary.copyWith(
              folderName: 'Mis archivos',
              clearFolder: true,
            ),
          )
        else
          doc,
    ];
    state = LibrarySnapshot(
      folders: state.folders.where((folder) => folder.id != id).toList(),
      documents: documents,
    );
    await _persist();
    await _enqueue(SyncJobType.deleteRemote, id);
  }

  Future<void> _touchFolder(String id) async {
    final folders = [
      for (final folder in state.folders)
        if (folder.id == id)
          folder.copyWith(updatedAt: DateTime.now())
        else
          folder,
    ];
    state = LibrarySnapshot(folders: folders, documents: state.documents);
    await _persist();
  }

  Future<List<SavedDocument>> search(
    String query, {
    bool recentsOnly = false,
    bool ocrOnly = false,
    bool pdfOnly = false,
  }) async {
    final q = query.trim();
    var docs = recentsOnly
        ? state.inCollection(LibraryCollections.recent)
        : state.activeDocuments;
    if (q.isNotEmpty) {
      final ids = await ref.read(libraryStoreProvider).searchIds(q);
      if (ids != null && ids.isNotEmpty) {
        final byId = {for (final doc in docs) doc.id: doc};
        docs = [
          for (final id in ids)
            if (byId[id] != null) byId[id]!,
        ];
      } else {
        final needle = q.toLowerCase();
        docs = docs.where((doc) {
          return doc.summary.name.toLowerCase().contains(needle) ||
              doc.summary.folderName.toLowerCase().contains(needle) ||
              doc.summary.ocrText.toLowerCase().contains(needle);
        }).toList();
      }
    }
    if (ocrOnly) {
      docs = docs.where((doc) => doc.summary.ocrText.trim().isNotEmpty).toList();
    }
    if (pdfOnly) {
      docs = docs
          .where((doc) => doc.summary.format.toUpperCase() == 'PDF')
          .toList();
    }
    return docs;
  }

  Future<void> mergeRemote({
    required List<SavedFolder> folders,
    required List<RemoteDocumentMeta> documents,
  }) async {
    var nextFolders = [...state.folders];
    for (final remote in folders) {
      final index = nextFolders.indexWhere((folder) => folder.id == remote.id);
      if (index < 0) {
        nextFolders.add(remote);
        continue;
      }
      if (!remote.updatedAt.isAfter(nextFolders[index].updatedAt)) continue;
      nextFolders[index] = nextFolders[index].copyWith(
        name: remote.name,
        updatedAt: remote.updatedAt,
        iconKey: remote.iconKey,
      );
    }

    var nextDocs = [...state.documents];
    for (final remote in documents) {
      final index = nextDocs.indexWhere((doc) => doc.id == remote.id);
      if (index < 0) continue;
      final local = nextDocs[index];
      if (!remote.updatedAt.isAfter(local.summary.updatedAt)) continue;
      nextDocs[index] = local.copyWith(
        summary: local.summary.copyWith(
          name: remote.name,
          format: remote.format,
          sizeBytes: remote.sizeBytes,
          folderId: remote.folderId,
          folderName: LibraryCollections.folderDisplayName(
            folderId: remote.folderId,
            folders: nextFolders,
          ),
          isFavorite: remote.isFavorite,
          deletedAt: remote.deletedAt,
          updatedAt: remote.updatedAt,
          createdAt: remote.createdAt ?? local.summary.createdAt,
          clearFolder: remote.folderId == null,
          clearDeletedAt: remote.deletedAt == null,
        ),
        pageCount: remote.pageCount,
      );
    }

    state = LibrarySnapshot(folders: nextFolders, documents: nextDocs);
    await _persist();
  }

  Future<void> importRestored(SavedDocument document) async {
    final existing = state.documentById(document.id);
    if (existing != null &&
        !document.summary.updatedAt.isAfter(existing.summary.updatedAt)) {
      return;
    }
    state = LibrarySnapshot(
      folders: state.folders,
      documents: [
        document,
        ...state.documents.where((doc) => doc.id != document.id),
      ],
    );
    await _persist();
  }

  Future<void> setDocumentSyncStatus(
    String id,
    SyncStatus status,
  ) async {
    await _updateDocument(
      id,
      (doc) => doc.copyWith(summary: doc.summary.copyWith(syncStatus: status)),
      enqueue: false,
    );
  }

  Future<void> _updateDocument(
    String id,
    SavedDocument Function(SavedDocument doc) transform, {
    bool enqueue = true,
  }) async {
    var changed = false;
    final documents = [
      for (final doc in state.documents)
        if (doc.id == id)
          () {
            changed = true;
            return transform(doc);
          }()
        else
          doc,
    ];
    if (!changed) return;
    state = LibrarySnapshot(folders: state.folders, documents: documents);
    await _persist();
    if (enqueue) {
      await _enqueue(SyncJobType.upsertMetadata, id);
    }
  }

  SyncStatus _initialSyncStatus() {
    return ref.read(sessionProvider).isAuthenticated
        ? SyncStatus.pendingUpload
        : SyncStatus.localOnly;
  }

  Future<void> _enqueue(SyncJobType type, String entityId) async {
    final session = ref.read(sessionProvider);
    if (!session.isAuthenticated) return;
    if (type == SyncJobType.uploadBackup && !session.backupEnabled) return;
    await ref.read(syncQueueProvider).enqueue(
      SyncJob(id: '${type.name}_$entityId', type: type, entityId: entityId),
    );
  }

  Future<void> enqueueBackupsForAll() async {
    if (!ref.read(sessionProvider).isAuthenticated) return;
    for (final doc in state.activeDocuments) {
      await _enqueue(SyncJobType.uploadBackup, doc.id);
    }
  }

  Future<void> _persist() async {
    await ref.read(libraryStoreProvider).save(state);
  }
}
