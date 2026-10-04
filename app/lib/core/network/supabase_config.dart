class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Cliente de URLs prefirmadas R2. El token S3 nunca vive en la app.
abstract interface class BackupSignedUrlClient {
  /// [size] is the exact byte length of the body; the URL is signed with
  /// that `Content-Length`, so R2 rejects any other size.
  Future<Uri> createUploadUrl({
    required String userId,
    required String documentId,
    required String backupId,
    required int size,
  });

  Future<Uri> createDownloadUrl({required String r2Key});

  Future<Uri> createDeleteUrl({required String r2Key});

  /// Per-user 32-byte backup pepper derived server-side. Requires a session.
  Future<List<int>> fetchBackupKey();
}
