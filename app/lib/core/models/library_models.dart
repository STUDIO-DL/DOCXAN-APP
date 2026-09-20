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

  FolderSummary copyWith({
    String? name,
    int? documentCount,
    DateTime? updatedAt,
  }) {
    return FolderSummary(
      id: id,
      name: name ?? this.name,
      documentCount: documentCount ?? this.documentCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'documentCount': documentCount,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory FolderSummary.fromJson(Map<String, dynamic> json) {
    return FolderSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      documentCount: json['documentCount'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
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
    this.ocrText = '',
  });

  final String id;
  final String name;
  final String format;
  final int sizeBytes;
  final String folderId;
  final String folderName;
  final DateTime updatedAt;
  final String ocrText;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'format': format,
    'sizeBytes': sizeBytes,
    'folderId': folderId,
    'folderName': folderName,
    'updatedAt': updatedAt.toIso8601String(),
    'ocrText': ocrText,
  };

  factory DocumentSummary.fromJson(Map<String, dynamic> json) {
    return DocumentSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String,
      sizeBytes: json['sizeBytes'] as int,
      folderId: json['folderId'] as String,
      folderName: json['folderName'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ocrText: json['ocrText'] as String? ?? '',
    );
  }
}
