import 'dart:convert';

import 'package:docxan/core/database/app_database.dart';
import 'package:docxan/core/library/library_collections.dart';
import 'package:docxan/core/library/library_snapshot.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/models/library_models.dart';
import 'package:docxan/core/models/saved_document.dart';
import 'package:docxan/core/models/saved_folder.dart';
import 'package:docxan/core/models/sync_status.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const catalogFile = 'catalog.json';

abstract interface class LibraryStore {
  Future<LibrarySnapshot> load();
  Future<void> save(LibrarySnapshot snapshot);
  Future<List<String>?> searchIds(String query);
}

class MemoryLibraryStore implements LibraryStore {
  MemoryLibraryStore([this.snapshot = const LibrarySnapshot()]);

  LibrarySnapshot snapshot;

  @override
  Future<LibrarySnapshot> load() async => snapshot;

  @override
  Future<void> save(LibrarySnapshot next) async {
    snapshot = next;
  }

  @override
  Future<List<String>?> searchIds(String query) async => null;
}

class JsonLibraryStore implements LibraryStore {
  JsonLibraryStore(this._files);

  final LocalFileStore _files;

  @override
  Future<LibrarySnapshot> load() async {
    final json = await _files.readJson(catalogFile);
    return snapshotFromJson(json);
  }

  @override
  Future<void> save(LibrarySnapshot snapshot) async {
    await _files.writeJson(catalogFile, snapshotToJson(snapshot));
  }

  @override
  Future<List<String>?> searchIds(String query) async => null;
}

class DriftLibraryStore implements LibraryStore {
  DriftLibraryStore(this._db, {this._migrateFrom});

  final AppDatabase _db;
  final LocalFileStore? _migrateFrom;
  var _migrated = false;

  @override
  Future<LibrarySnapshot> load() async {
    await _migrateLegacyJson();
    final folders = await _db.select(_db.folders).get();
    final documents = await _db.select(_db.documents).get();
    final pages = await _db.select(_db.documentPages).get();
    final pagesByDoc = <String, List<PageRow>>{};
    for (final page in pages) {
      pagesByDoc.putIfAbsent(page.documentId, () => []).add(page);
    }
    return canonicalizeSnapshot(
      LibrarySnapshot(
        folders: [for (final row in folders) _folderFromRow(row)],
        documents: [
          for (final row in documents)
            _documentFromRow(row, pagesByDoc[row.id] ?? const []),
        ],
      ),
    );
  }

  @override
  Future<void> save(LibrarySnapshot snapshot) async {
    final canonical = canonicalizeSnapshot(snapshot);
    await _db.transaction(() async {
      await _db.delete(_db.folders).go();
      await _db.delete(_db.documents).go();
      await _db.delete(_db.documentPages).go();
      for (final folder in canonical.folders) {
        await _db.into(_db.folders).insertOnConflictUpdate(_folderToRow(folder));
      }
      for (final doc in canonical.documents) {
        await _db
            .into(_db.documents)
            .insertOnConflictUpdate(_documentToRow(doc));
        for (var i = 0; i < doc.pagePaths.length; i++) {
          await _db
              .into(_db.documentPages)
              .insertOnConflictUpdate(
                DocumentPagesCompanion.insert(
                  id: '${doc.id}_$i',
                  documentId: doc.id,
                  pageIndex: i,
                  localPath: doc.pagePaths[i],
                ),
              );
        }
        await _db.rebuildDocumentFts(
          documentId: doc.id,
          name: doc.summary.name,
          folderName: doc.summary.folderName,
          ocrText: doc.summary.ocrText,
        );
      }
    });
  }

  @override
  Future<List<String>?> searchIds(String query) async {
    final ids = await _db.searchFts(query);
    return ids;
  }

  Future<void> _migrateLegacyJson() async {
    if (_migrated) return;
    _migrated = true;
    final existing = await _db.select(_db.folders).get();
    if (existing.isNotEmpty) return;
    final files = _migrateFrom;
    if (files == null) return;
    try {
      final json = await files.readJson(catalogFile);
      final snapshot = snapshotFromJson(json);
      if (snapshot.folders.isEmpty && snapshot.documents.isEmpty) return;
      await save(snapshot);
      AppLogger.debug('Migrated catalog.json into Drift');
    } catch (error) {
      AppLogger.debug('catalog.json migrate skipped: $error');
    }
  }
}

LibrarySnapshot snapshotFromJson(Map<String, dynamic>? json) {
  if (json == null) return const LibrarySnapshot();
  final folders = <SavedFolder>[];
  final documents = <SavedDocument>[];
  final rawFolders = json['folders'];
  if (rawFolders is List) {
    for (final item in rawFolders) {
      if (item is Map) {
        folders.add(SavedFolder.fromJson(Map<String, dynamic>.from(item)));
      }
    }
  }
  final rawDocs = json['documents'];
  if (rawDocs is List) {
    for (final item in rawDocs) {
      if (item is Map) {
        documents.add(SavedDocument.fromJson(Map<String, dynamic>.from(item)));
      }
    }
  }
  return canonicalizeSnapshot(
    LibrarySnapshot(folders: folders, documents: documents),
  );
}

Map<String, dynamic> snapshotToJson(LibrarySnapshot snapshot) {
  final canonical = canonicalizeSnapshot(snapshot);
  return {
    'folders': canonical.folders.map((folder) => folder.toJson()).toList(),
    'documents': canonical.documents.map((doc) => doc.toJson()).toList(),
  };
}

LibrarySnapshot canonicalizeSnapshot(LibrarySnapshot snapshot) {
  final folders = [
    for (final folder in snapshot.folders)
      folder.copyWith(
        id: DefaultFolders.canonicalize(folder.id),
        iconKey: folder.iconKey == 'folder'
            ? DefaultFolders.iconKeyFor(folder.id)
            : folder.iconKey,
      ),
  ];
  final documents = [
    for (final doc in snapshot.documents)
      doc.copyWith(
        summary: doc.summary.copyWith(
          folderId: DefaultFolders.canonicalizeNullable(doc.summary.folderId),
          folderName: LibraryCollections.folderDisplayName(
            folderId: DefaultFolders.canonicalizeNullable(doc.summary.folderId),
            folders: folders,
          ),
          clearFolder:
              DefaultFolders.canonicalizeNullable(doc.summary.folderId) == null,
        ),
      ),
  ];
  return LibrarySnapshot(folders: folders, documents: documents);
}

SavedFolder _folderFromRow(FolderRow row) {
  return SavedFolder(
    id: row.id,
    name: row.name,
    updatedAt: row.updatedAt,
    isDefault: row.isDefault,
    iconKey: row.iconKey,
  );
}

FoldersCompanion _folderToRow(SavedFolder folder) {
  return FoldersCompanion(
    id: Value(folder.id),
    name: Value(folder.name),
    iconKey: Value(folder.iconKey),
    isDefault: Value(folder.isDefault),
    createdAt: Value(folder.updatedAt),
    updatedAt: Value(folder.updatedAt),
  );
}

SavedDocument _documentFromRow(DocumentRow row, List<PageRow> pages) {
  final paths = <String>[];
  if (pages.isNotEmpty) {
    final ordered = [...pages]..sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
    for (final page in ordered) {
      if (page.localPath.isNotEmpty) paths.add(page.localPath);
    }
  } else {
    final decoded = jsonDecode(row.pagePathsJson);
    if (decoded is List) {
      for (final item in decoded) {
        if (item is String && item.isNotEmpty) paths.add(item);
      }
    }
  }
  return SavedDocument(
    summary: DocumentSummary(
      id: row.id,
      name: row.name,
      format: row.format,
      sizeBytes: row.sizeBytes,
      folderId: row.folderId,
      folderName: row.folderName,
      updatedAt: row.updatedAt,
      ocrText: row.ocrText,
      isFavorite: row.isFavorite,
      deletedAt: row.deletedAt,
      createdAt: row.createdAt,
      syncStatus: SyncStatus.fromWire(row.syncStatus),
    ),
    pdfPath: row.pdfPath,
    previewPath: row.previewPath,
    pageCount: row.pageCount,
    pagePaths: paths,
  );
}

DocumentsCompanion _documentToRow(SavedDocument doc) {
  final summary = doc.summary;
  return DocumentsCompanion(
    id: Value(summary.id),
    name: Value(summary.name),
    format: Value(summary.format),
    sizeBytes: Value(summary.sizeBytes),
    folderId: Value(summary.folderId),
    folderName: Value(summary.folderName),
    ocrText: Value(summary.ocrText),
    isFavorite: Value(summary.isFavorite),
    deletedAt: Value(summary.deletedAt),
    createdAt: Value(summary.createdAt ?? summary.updatedAt),
    updatedAt: Value(summary.updatedAt),
    pdfPath: Value(doc.pdfPath),
    previewPath: Value(doc.previewPath),
    pageCount: Value(doc.pageCount),
    pagePathsJson: Value(jsonEncode(doc.pagePaths)),
    syncStatus: Value(summary.syncStatus.wireName),
  );
}

final libraryStoreProvider = Provider<LibraryStore>((ref) {
  final db = ref.watch(appDatabaseProvider);
  if (db != null) {
    return DriftLibraryStore(
      db,
      migrateFrom: ref.watch(localFileStoreProvider),
    );
  }
  return JsonLibraryStore(ref.watch(localFileStoreProvider));
});
