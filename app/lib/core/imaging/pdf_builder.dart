import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Top-level isolate entry. Builds a multipage A4 PDF from JPEG bytes.
Future<Uint8List> buildPdfIsolate(List<Uint8List> pages) async {
  final doc = pw.Document();
  for (final bytes in pages) {
    final image = pw.MemoryImage(bytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
        },
      ),
    );
  }
  return Uint8List.fromList(await doc.save());
}
