import 'package:doxan/core/sync/sync_manager.dart';
import 'package:doxan/features/backup/domain/repositories/backup_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._sync);

  final SyncManager _sync;

  @override
  Future<void> uploadEncrypted(String documentId) async {
    await _sync.synchronize();
  }

  @override
  Future<void> restoreAll({required String pin}) =>
      _sync.restoreFromCloud(pin: pin);
}

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl(ref.watch(syncManagerProvider));
});
