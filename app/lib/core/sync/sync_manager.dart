import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/core/errors/app_failure.dart';
import 'package:docxan/core/export/backup_archive.dart';
import 'package:docxan/core/library/library_ids.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/models/sync_status.dart';
import 'package:docxan/core/security/backup_crypto.dart';
import 'package:docxan/core/security/pin_service.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:docxan/core/storage/r2_storage_service.dart';
import 'package:docxan/core/sync/remote_metadata_client.dart';
import 'package:docxan/core/sync/sync_queue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncRunStatus { idle, running, success, failed, skipped }

class SyncReport {
  const SyncReport({
    required this.status,
    this.uploaded = 0,
    this.restored = 0,
    this.failed = 0,
    this.message,
    this.messageKey,
  });

  final SyncRunStatus status;
  final int uploaded;
  final int restored;
  final int failed;
  final String? message;
  final String? messageKey;

  bool get ok => status == SyncRunStatus.success || status == SyncRunStatus.idle;
}

String localizedSyncReport(AppLocalizations l10n, SyncReport report) {
  return switch (report.messageKey) {
    'need_account' => l10n.syncNeedAccount,
    'not_configured' => l10n.syncNotConfigured,
    'nothing_pending' => l10n.syncNothingPending,
    'complete' => l10n.syncComplete,
    'need_pin' => l10n.pin,
    'failed' => l10n.syncFailedMessage,
    'restore_complete' => l10n.restoreComplete,
    'restore_failed' => l10n.restoreFailed,
    _ => l10n.syncComplete,
  };
}

class SyncManager {
  SyncManager(this._ref);

  final Ref _ref;

  Future<SyncReport> synchronize() async {
    final session = _ref.read(sessionProvider);
    if (!session.isAuthenticated || session.userId == null) {
      return const SyncReport(
        status: SyncRunStatus.skipped,
        messageKey: 'need_account',
      );
    }
    final storage = _ref.read(r2StorageServiceProvider);
    if (!storage.isConfigured) {
      return const SyncReport(
        status: SyncRunStatus.skipped,
        messageKey: 'not_configured',
      );
    }

    final remote = _ref.read(remoteMetadataClientProvider);
    final catalog = _ref.read(libraryCatalogProvider.notifier);
    try {
      await catalog.mergeRemote(
        folders: await remote.fetchFolders(),
        documents: await remote.fetchDocuments(),
      );
    } catch (error) {
      AppLogger.debug('Metadata pull skipped: $error');
    }

    final queue = _ref.read(syncQueueProvider);
    final jobs = await queue.pending();
    if (jobs.isEmpty) {
      return const SyncReport(
        status: SyncRunStatus.success,
        messageKey: 'nothing_pending',
      );
    }

    var uploaded = 0;
    var failed = 0;
    String? lastError;
    final userId = session.userId!;

    for (final job in jobs) {
      await queue.mark(job.id, SyncStatus.uploading);
      if (job.type != SyncJobType.deleteRemote) {
        await catalog.setDocumentSyncStatus(job.entityId, SyncStatus.uploading);
      }
      try {
        await _runJob(job, userId: userId, storage: storage, remote: remote);
        await queue.mark(job.id, SyncStatus.synced);
        if (job.type != SyncJobType.deleteRemote) {
          await catalog.setDocumentSyncStatus(job.entityId, SyncStatus.synced);
        }
        uploaded += 1;
      } catch (error) {
        AppLogger.debug('Sync job ${job.id} failed: $error');
        lastError = error is AppFailure ? error.message : error.toString();
        await queue.mark(job.id, SyncStatus.failed, error: lastError);
        if (job.type != SyncJobType.deleteRemote) {
          await catalog.setDocumentSyncStatus(job.entityId, SyncStatus.failed);
        }
        failed += 1;
      }
    }

    if (failed > 0 && uploaded == 0) {
      return SyncReport(
        status: SyncRunStatus.failed,
        failed: failed,
        messageKey: lastError == 'need_pin' ? 'need_pin' : 'failed',
      );
    }
    return SyncReport(
      status: failed > 0 ? SyncRunStatus.failed : SyncRunStatus.success,
      uploaded: uploaded,
      failed: failed,
      messageKey: failed > 0
          ? (lastError == 'need_pin' ? 'need_pin' : 'failed')
          : 'complete',
    );
  }

  Future<SyncReport> restoreFromCloud({required String pin}) async {
    final session = _ref.read(sessionProvider);
    final userId = session.userId;
    if (!session.isAuthenticated || userId == null) {
      return const SyncReport(
        status: SyncRunStatus.skipped,
        messageKey: 'need_account',
      );
    }
    if (pin.length < 4) {
      return const SyncReport(
        status: SyncRunStatus.failed,
        messageKey: 'need_pin',
      );
    }
    final storage = _ref.read(r2StorageServiceProvider);
    final remote = _ref.read(remoteMetadataClientProvider);
    final catalog = _ref.read(libraryCatalogProvider.notifier);
    final files = _ref.read(localFileStoreProvider);
    final backups = await remote.fetchBackups();
    if (backups.isEmpty) {
      return const SyncReport(
        status: SyncRunStatus.success,
        messageKey: 'nothing_pending',
      );
    }

    var restored = 0;
    var failed = 0;
    String? lastError;
    for (final backup in backups) {
      try {
        final cipher = await storage.downloadDocument(
          userId: userId,
          documentId: backup.documentId,
          r2Key: backup.r2Key,
        );
        final zip = await BackupCrypto.decrypt(blob: cipher, pin: pin);
        final packed = BackupArchive.filesOf(zip);
        final pdfBytes = packed['document.pdf'] ?? const <int>[];
        final pageEntries = packed.entries
            .where((entry) => entry.key.startsWith('pages/'))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final pdfPath = await files.writeBytes(
          '${backup.documentId}/document.pdf',
          pdfBytes,
        );
        final pagePaths = <String>[];
        for (var i = 0; i < pageEntries.length; i++) {
          pagePaths.add(
            await files.writeBytes(
              '${backup.documentId}/page_$i.jpg',
              pageEntries[i].value,
            ),
          );
        }
        final previewBytes = packed['preview.jpg'];
        final previewPath = pagePaths.isNotEmpty
            ? pagePaths.first
            : previewBytes == null
            ? ''
            : await files.writeBytes(
                '${backup.documentId}/preview.jpg',
                previewBytes,
              );
        final unpacked = BackupArchive.unpack(
          zip,
          pdfPath: pdfPath,
          previewPath: previewPath,
          pagePaths: pagePaths,
        );
        await catalog.importRestored(
          unpacked.copyWith(
            summary: unpacked.summary.copyWith(syncStatus: SyncStatus.synced),
          ),
        );
        restored += 1;
      } catch (error) {
        AppLogger.debug('Restore ${backup.documentId} failed: $error');
        lastError = error.toString();
        failed += 1;
      }
    }

    try {
      await catalog.mergeRemote(
        folders: await remote.fetchFolders(),
        documents: await remote.fetchDocuments(),
      );
    } catch (error) {
      AppLogger.debug('Restore metadata merge skipped: $error');
    }

    if (restored == 0 && failed > 0) {
      return SyncReport(
        status: SyncRunStatus.failed,
        failed: failed,
        messageKey: 'restore_failed',
        message: lastError,
      );
    }
    return SyncReport(
      status: SyncRunStatus.success,
      restored: restored,
      failed: failed,
      messageKey: 'restore_complete',
    );
  }

  Future<void> _runJob(
    SyncJob job, {
    required String userId,
    required R2StorageService storage,
    required RemoteMetadataClient remote,
  }) async {
    final library = _ref.read(libraryCatalogProvider);
    switch (job.type) {
      case SyncJobType.upsertMetadata:
        final folder = library.folderById(job.entityId);
        if (folder != null) {
          await remote.upsertFolder(userId: userId, folder: folder);
          return;
        }
        final document = library.documentById(job.entityId);
        if (document != null) {
          await remote.upsertDocument(userId: userId, document: document);
        }
      case SyncJobType.uploadBackup:
        final document = library.documentById(job.entityId);
        if (document == null) return;
        final pin = _ref.read(pinServiceProvider).verifiedPin;
        if (pin == null || pin.isEmpty) {
          throw const CryptoFailure('need_pin');
        }
        await remote.upsertDocument(userId: userId, document: document);
        final zip = BackupArchive.pack(document);
        final cipher = await BackupCrypto.encrypt(plaintext: zip, pin: pin);
        await storage.uploadDocument(
          userId: userId,
          documentId: LibraryIds.remoteUuid(document.id),
          bytes: cipher,
        );
        await remote.upsertBackup(
          userId: userId,
          documentId: document.id,
          backupId: LibraryIds.remoteUuid('backup-${document.id}-current'),
          r2Key: R2StorageService.objectKey(
            userId,
            LibraryIds.remoteUuid(document.id),
            'current',
          ),
          encryptedSize: cipher.length,
        );
      case SyncJobType.deleteRemote:
        try {
          await storage.deleteDocument(
            userId: userId,
            documentId: LibraryIds.remoteUuid(job.entityId),
          );
        } on AppFailure {
          // El blob puede no existir aún.
        }
        try {
          await remote.deleteBackup(documentId: job.entityId);
          await remote.deleteDocument(job.entityId);
          await remote.deleteFolder(job.entityId);
        } on AppFailure {
          rethrow;
        }
    }
  }
}

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(ref);
});
