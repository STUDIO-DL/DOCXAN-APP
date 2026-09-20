import 'package:doxan/core/errors/app_failure.dart';
import 'package:doxan/core/library/library_ids.dart';
import 'package:doxan/core/logging/app_logger.dart';
import 'package:doxan/core/models/profile.dart';
import 'package:doxan/core/models/remote_document_meta.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:doxan/core/models/saved_folder.dart';
import 'package:doxan/core/models/sync_status.dart';
import 'package:doxan/core/models/user_settings.dart';
import 'package:doxan/core/network/doxan_supabase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Metadatos remotos. Nunca envía OCR ni blobs.
class RemoteMetadataClient {
  bool get isReady => DoxanSupabase.isReady;

  Future<void> upsertProfile(Profile profile) async {
    if (!isReady) return;
    try {
      await DoxanSupabase.client.from('profiles').upsert({
        'id': profile.id,
        'email': profile.email,
        'display_name': profile.displayName,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      AppLogger.debug('Profile upsert skipped: $error');
      throw NetworkFailure('$error');
    }
  }

  Future<void> upsertFolder({
    required String userId,
    required SavedFolder folder,
  }) async {
    if (!isReady) return;
    await DoxanSupabase.client.from('folders').upsert({
      'id': LibraryIds.remoteUuid(folder.id),
      'user_id': userId,
      'name': folder.name,
      'icon_key': folder.iconKey,
      'updated_at': folder.updatedAt.toIso8601String(),
    });
  }

  Future<void> upsertDocument({
    required String userId,
    required SavedDocument document,
  }) async {
    if (!isReady) return;
    final summary = document.summary;
    await DoxanSupabase.client.from('documents').upsert({
      'id': LibraryIds.remoteUuid(summary.id),
      'user_id': userId,
      'folder_id': summary.folderId == null
          ? null
          : LibraryIds.remoteUuid(summary.folderId!),
      'name': summary.name,
      'format': summary.format,
      'size_bytes': summary.sizeBytes,
      'page_count': document.pageCount,
      'is_favorite': summary.isFavorite,
      'deleted_at': summary.deletedAt?.toIso8601String(),
      'sync_status': SyncStatus.synced.wireName,
      'updated_at': summary.updatedAt.toIso8601String(),
    });
  }

  Future<void> deleteDocument(String documentId) async {
    if (!isReady) return;
    await DoxanSupabase.client
        .from('documents')
        .delete()
        .eq('id', LibraryIds.remoteUuid(documentId));
  }

  Future<void> deleteFolder(String folderId) async {
    if (!isReady) return;
    await DoxanSupabase.client
        .from('folders')
        .delete()
        .eq('id', LibraryIds.remoteUuid(folderId));
  }

  Future<void> upsertSettings({
    required String userId,
    required UserSettings settings,
  }) async {
    if (!isReady) return;
    await DoxanSupabase.client.from('user_settings').upsert({
      'user_id': userId,
      'compression_profile': settings.compressionProfile,
      'backup_enabled': settings.backupEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertBackup({
    required String userId,
    required String documentId,
    required String backupId,
    required String r2Key,
    required int encryptedSize,
  }) async {
    if (!isReady) return;
    await DoxanSupabase.client.from('backups').upsert({
      'id': backupId,
      'user_id': userId,
      'document_id': LibraryIds.remoteUuid(documentId),
      'r2_key': r2Key,
      'encrypted_size': encryptedSize,
    });
  }

  Future<void> deleteBackup({required String documentId}) async {
    if (!isReady) return;
    await DoxanSupabase.client
        .from('backups')
        .delete()
        .eq('document_id', LibraryIds.remoteUuid(documentId));
  }

  Future<List<SavedFolder>> fetchFolders() async {
    if (!isReady) return const [];
    final rows = await DoxanSupabase.client.from('folders').select();
    return [
      for (final row in rows.cast<Map<String, dynamic>>())
        SavedFolder(
          id: row['id'] as String,
          name: row['name'] as String? ?? 'Carpeta',
          updatedAt:
              DateTime.tryParse(row['updated_at'] as String? ?? '') ??
              DateTime.now(),
          iconKey: row['icon_key'] as String? ?? 'folder',
        ),
    ];
  }

  Future<List<RemoteDocumentMeta>> fetchDocuments() async {
    if (!isReady) return const [];
    final rows = await DoxanSupabase.client.from('documents').select();
    return [
      for (final row in rows.cast<Map<String, dynamic>>())
        RemoteDocumentMeta(
          id: row['id'] as String,
          name: row['name'] as String? ?? 'Documento',
          format: row['format'] as String? ?? 'PDF',
          sizeBytes: (row['size_bytes'] as num?)?.toInt() ?? 0,
          folderId: row['folder_id'] as String?,
          pageCount: (row['page_count'] as num?)?.toInt() ?? 1,
          isFavorite: row['is_favorite'] as bool? ?? false,
          deletedAt: DateTime.tryParse(row['deleted_at'] as String? ?? ''),
          updatedAt:
              DateTime.tryParse(row['updated_at'] as String? ?? '') ??
              DateTime.now(),
          createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
        ),
    ];
  }

  Future<List<RemoteBackupRef>> fetchBackups() async {
    if (!isReady) return const [];
    final rows = await DoxanSupabase.client
        .from('backups')
        .select()
        .order('created_at', ascending: false);
    return [
      for (final row in rows.cast<Map<String, dynamic>>())
        RemoteBackupRef(
          id: row['id'] as String,
          documentId: row['document_id'] as String,
          r2Key: row['r2_key'] as String,
          encryptedSize: (row['encrypted_size'] as num?)?.toInt() ?? 0,
          createdAt:
              DateTime.tryParse(row['created_at'] as String? ?? '') ??
              DateTime.now(),
        ),
    ];
  }
}

final remoteMetadataClientProvider = Provider<RemoteMetadataClient>((ref) {
  return RemoteMetadataClient();
});
