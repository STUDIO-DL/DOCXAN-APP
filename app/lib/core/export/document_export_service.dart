import 'dart:typed_data';

import 'package:doxan/core/export/docx_builder.dart';
import 'package:doxan/core/export/image_export.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExportFormat { pdf, docx, jpg, png }

class DocumentExportService {
  const DocumentExportService();

  Future<Uint8List> exportPdf(SavedDocument document) {
    return readPageBytes(document.pdfPath);
  }

  Future<Uint8List> exportDocx(SavedDocument document) async {
    return buildDocxFromText(document.summary.ocrText);
  }

  Future<List<Uint8List>> exportJpg(SavedDocument document) async {
    final paths = document.imagePaths;
    final pages = <Uint8List>[];
    for (final path in paths) {
      pages.add(await readPageBytes(path));
    }
    return pages;
  }

  Future<List<Uint8List>> exportPng(SavedDocument document) async {
    final paths = document.imagePaths;
    final pages = <Uint8List>[];
    for (final path in paths) {
      pages.add(await pageAsPng(path));
    }
    return pages;
  }
}

final documentExportServiceProvider = Provider<DocumentExportService>((ref) {
  return const DocumentExportService();
});
