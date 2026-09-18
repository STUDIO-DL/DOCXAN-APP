class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Cliente de URLs prefirmadas R2. El token S3 nunca vive en la app.
abstract interface class BackupSignedUrlClient {
  Future<Uri> createUploadUrl({
    required String userId,
    required String documentId,
    required String backupId,
  });

  Future<Uri> createDownloadUrl({required String r2Key});
}
