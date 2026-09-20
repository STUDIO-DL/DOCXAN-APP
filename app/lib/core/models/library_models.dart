import 'package:doxan/core/models/sync_status.dart';

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
}

class DocumentSummary {
  const DocumentSummary({
    required this.id,
    required this.name,
    required this.format,
    required this.sizeBytes,
    required this.folderName,
    required this.updatedAt,
    required this.ocrText,
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
}
