import 'package:doxan/core/models/library_models.dart';
import 'package:doxan/core/models/sync_status.dart';

class SavedDocument {
  const SavedDocument({
    required this.summary,
    required this.pdfPath,
    required this.previewPath,
    this.pageCount = 1,
    this.pagePaths = const [],
  });

  final DocumentSummary summary;
  final String pdfPath;
  final String previewPath;
  final int pageCount;
  final List<String> pagePaths;

  String get id => summary.id;

  List<String> get imagePaths {
    if (pagePaths.isNotEmpty) return pagePaths;
    if (previewPath.isNotEmpty) return [previewPath];
    return const [];
  }

  SavedDocument copyWith({
    DocumentSummary? summary,
    String? pdfPath,
    String? previewPath,
    int? pageCount,
    List<String>? pagePaths,
  }) {
    return SavedDocument(
      summary: summary ?? this.summary,
      pdfPath: pdfPath ?? this.pdfPath,
      previewPath: previewPath ?? this.previewPath,
      pageCount: pageCount ?? this.pageCount,
      pagePaths: pagePaths ?? this.pagePaths,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': summary.id,
    'name': summary.name,
    'format': summary.format,
    'sizeBytes': summary.sizeBytes,
    'folderId': summary.folderId,
    'folderName': summary.folderName,
    'updatedAt': summary.updatedAt.toIso8601String(),
    'ocrText': summary.ocrText,
    'pdfPath': pdfPath,
    'previewPath': previewPath,
    'pageCount': pageCount,
    'pagePaths': pagePaths,
    'isFavorite': summary.isFavorite,
    'deletedAt': summary.deletedAt?.toIso8601String(),
    'createdAt': (summary.createdAt ?? summary.updatedAt).toIso8601String(),
    'syncStatus': summary.syncStatus.wireName,
  };

  factory SavedDocument.fromJson(Map<String, dynamic> json) {
    final folderId = _normalizeFolderId(json['folderId'] as String?);
    final pagePaths = <String>[];
    final rawPages = json['pagePaths'];
    if (rawPages is List) {
      for (final item in rawPages) {
        if (item is String && item.isNotEmpty) pagePaths.add(item);
      }
    }
    final updatedAt =
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now();
    return SavedDocument(
      summary: DocumentSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        format: json['format'] as String? ?? 'PDF',
        sizeBytes: json['sizeBytes'] as int? ?? 0,
        folderId: folderId,
        folderName: json['folderName'] as String? ?? 'Mis archivos',
        updatedAt: updatedAt,
        ocrText: json['ocrText'] as String? ?? '',
        isFavorite: json['isFavorite'] as bool? ?? false,
        deletedAt: DateTime.tryParse(json['deletedAt'] as String? ?? ''),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ?? updatedAt,
        syncStatus: SyncStatus.fromWire(json['syncStatus'] as String?),
      ),
      pdfPath: json['pdfPath'] as String? ?? '',
      previewPath: json['previewPath'] as String? ?? '',
      pageCount: json['pageCount'] as int? ?? 1,
      pagePaths: pagePaths,
    );
  }
}

String? _normalizeFolderId(String? id) {
  if (id == null || id.isEmpty || id == 'scans') return null;
  return id;
}
