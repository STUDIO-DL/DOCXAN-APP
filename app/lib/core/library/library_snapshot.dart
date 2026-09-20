import 'package:docxan/core/library/library_collections.dart';
import 'package:docxan/core/models/library_models.dart';
import 'package:docxan/core/models/saved_document.dart';
import 'package:docxan/core/models/saved_folder.dart';
import 'package:docxan/core/models/sync_status.dart';

class LibrarySnapshot {
  const LibrarySnapshot({
    this.folders = const [],
    this.documents = const [],
  });

  final List<SavedFolder> folders;
  final List<SavedDocument> documents;

  SavedDocument? documentById(String id) {
    for (final doc in documents) {
      if (doc.id == id) return doc;
    }
    return null;
  }

  SavedFolder? folderById(String id) {
    for (final folder in folders) {
      if (folder.id == id) return folder;
    }
    return null;
  }

  List<SavedDocument> get activeDocuments {
    return documents.where((doc) => !doc.summary.isDeleted).toList();
  }

  List<SavedDocument> inCollection(String collectionId, {DateTime? now}) {
    return LibraryCollections.filter(documents, collectionId, now: now);
  }

  SyncStatus get aggregateSyncStatus {
    final active = activeDocuments;
    if (active.isEmpty) return SyncStatus.localOnly;
    var hasFailed = false;
    var hasUploading = false;
    var hasPending = false;
    var hasSynced = false;
    for (final doc in active) {
      switch (doc.summary.syncStatus) {
        case SyncStatus.failed:
          hasFailed = true;
        case SyncStatus.uploading:
          hasUploading = true;
        case SyncStatus.pendingUpload:
          hasPending = true;
        case SyncStatus.synced:
          hasSynced = true;
        case SyncStatus.localOnly:
          break;
      }
    }
    if (hasUploading) return SyncStatus.uploading;
    if (hasFailed) return SyncStatus.failed;
    if (hasPending) return SyncStatus.pendingUpload;
    if (hasSynced) return SyncStatus.synced;
    return SyncStatus.localOnly;
  }

  FolderSummary folderSummary(SavedFolder folder) {
    final count = documents
        .where(
          (doc) =>
              !doc.summary.isDeleted && doc.summary.folderId == folder.id,
        )
        .length;
    return FolderSummary(
      id: folder.id,
      name: folder.name,
      documentCount: count,
      updatedAt: folder.updatedAt,
      isDefault: folder.isDefault,
    );
  }
}
