class FolderSummary {
  const FolderSummary({
    required this.id,
    required this.name,
    required this.documentCount,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int documentCount;
  final DateTime updatedAt;
}

class DocumentSummary {
  const DocumentSummary({
    required this.id,
    required this.name,
    required this.format,
    required this.sizeBytes,
    required this.folderId,
    required this.folderName,
    required this.updatedAt,
    required this.ocrText,
    this.isDemo = false,
  });

  final String id;
  final String name;
  final String format;
  final int sizeBytes;
  final String folderId;
  final String folderName;
  final DateTime updatedAt;
  final String ocrText;
  final bool isDemo;
}
