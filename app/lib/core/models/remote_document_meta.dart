class RemoteDocumentMeta {
  const RemoteDocumentMeta({
    required this.id,
    required this.name,
    required this.format,
    required this.sizeBytes,
    required this.updatedAt,
    this.folderId,
    this.pageCount = 1,
    this.isFavorite = false,
    this.deletedAt,
    this.createdAt,
  });

  final String id;
  final String name;
  final String format;
  final int sizeBytes;
  final String? folderId;
  final int pageCount;
  final bool isFavorite;
  final DateTime? deletedAt;
  final DateTime updatedAt;
  final DateTime? createdAt;
}

class RemoteBackupRef {
  const RemoteBackupRef({
    required this.id,
    required this.documentId,
    required this.r2Key,
    required this.encryptedSize,
    required this.createdAt,
  });

  final String id;
  final String documentId;
  final String r2Key;
  final int encryptedSize;
  final DateTime createdAt;
}
