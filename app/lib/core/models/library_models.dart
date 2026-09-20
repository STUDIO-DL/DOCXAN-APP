import 'package:docxan/core/models/sync_status.dart';

class FolderSummary {
  const FolderSummary({
    required this.id,
    required this.name,
    required this.documentCount,
    required this.updatedAt,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final int documentCount;
  final DateTime updatedAt;
  final bool isDefault;

  FolderSummary copyWith({
    String? name,
    int? documentCount,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return FolderSummary(
      id: id,
      name: name ?? this.name,
      documentCount: documentCount ?? this.documentCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'documentCount': documentCount,
    'updatedAt': updatedAt.toIso8601String(),
    'isDefault': isDefault,
  };

  factory FolderSummary.fromJson(Map<String, dynamic> json) {
    return FolderSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      documentCount: json['documentCount'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class DocumentSummary {
  const DocumentSummary({
    required this.id,
    required this.name,
    required this.format,
    required this.sizeBytes,
    required this.folderName,
    required this.updatedAt,
    this.ocrText = '',
    this.folderId,
    this.isDemo = false,
    this.isFavorite = false,
    this.deletedAt,
    this.createdAt,
    this.syncStatus = SyncStatus.localOnly,
  });

  final String id;
  final String name;
  final String format;
  final int sizeBytes;
  final String? folderId;
  final String folderName;
  final DateTime updatedAt;
  final String ocrText;
  final bool isDemo;
  final bool isFavorite;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final SyncStatus syncStatus;

  bool get isDeleted => deletedAt != null;

  DocumentSummary copyWith({
    String? id,
    String? name,
    String? format,
    int? sizeBytes,
    String? folderId,
    String? folderName,
    DateTime? updatedAt,
    String? ocrText,
    bool? isDemo,
    bool? isFavorite,
    DateTime? deletedAt,
    DateTime? createdAt,
    SyncStatus? syncStatus,
    bool clearFolder = false,
    bool clearDeletedAt = false,
  }) {
    return DocumentSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      format: format ?? this.format,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
      folderName: folderName ?? this.folderName,
      updatedAt: updatedAt ?? this.updatedAt,
      ocrText: ocrText ?? this.ocrText,
      isDemo: isDemo ?? this.isDemo,
      isFavorite: isFavorite ?? this.isFavorite,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'format': format,
    'sizeBytes': sizeBytes,
    'folderId': folderId,
    'folderName': folderName,
    'updatedAt': updatedAt.toIso8601String(),
    'ocrText': ocrText,
    'isDemo': isDemo,
    'isFavorite': isFavorite,
    'deletedAt': deletedAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'syncStatus': syncStatus.name,
  };

  factory DocumentSummary.fromJson(Map<String, dynamic> json) {
    return DocumentSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String,
      sizeBytes: json['sizeBytes'] as int,
      folderId: json['folderId'] as String?,
      folderName: json['folderName'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ocrText: json['ocrText'] as String? ?? '',
      isDemo: json['isDemo'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      syncStatus: SyncStatus.values.firstWhere(
        (value) => value.name == json['syncStatus'],
        orElse: () => SyncStatus.localOnly,
      ),
    );
  }
}
