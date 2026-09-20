import 'dart:typed_data';

/// Payload that Scan (or any capture flow) hands to [LibraryWriter].
class DocumentDraft {
  const DocumentDraft({
    required this.id,
    required this.name,
    required this.pdfBytes,
    required this.previewJpeg,
    required this.ocrText,
    required this.pageCount,
    this.pageJpegs = const [],
    this.folderId,
  });

  final String id;
  final String name;
  final Uint8List pdfBytes;
  final Uint8List previewJpeg;
  final String ocrText;
  final int pageCount;
  final List<Uint8List> pageJpegs;
  final String? folderId;
}
