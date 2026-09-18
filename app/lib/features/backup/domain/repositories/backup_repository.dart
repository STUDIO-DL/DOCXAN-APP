abstract interface class BackupRepository {
  Future<void> uploadEncrypted(String documentId);
  Future<void> restoreAll();
}
