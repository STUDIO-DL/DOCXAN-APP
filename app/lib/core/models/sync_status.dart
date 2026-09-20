/// Estado de sincronización de un documento o trabajo de cola.
enum SyncStatus {
  localOnly,
  pendingUpload,
  uploading,
  synced,
  failed;

  static const localWire = 'local_only';
  static const pendingWire = 'pending_upload';
  static const uploadingWire = 'uploading';
  static const syncedWire = 'synced';
  static const failedWire = 'failed';

  String get wireName {
    return switch (this) {
      SyncStatus.localOnly => localWire,
      SyncStatus.pendingUpload => pendingWire,
      SyncStatus.uploading => uploadingWire,
      SyncStatus.synced => syncedWire,
      SyncStatus.failed => failedWire,
    };
  }

  static SyncStatus fromWire(String? raw) {
    return switch (raw) {
      pendingWire || 'pending' => SyncStatus.pendingUpload,
      uploadingWire => SyncStatus.uploading,
      syncedWire || 'remote' => SyncStatus.synced,
      failedWire => SyncStatus.failed,
      _ => SyncStatus.localOnly,
    };
  }
}
