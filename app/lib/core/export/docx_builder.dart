import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Minimal linear .docx from OCR text. No PDF layout.
Uint8List buildDocxFromText(String text) {
  final body = text.trim().isEmpty ? ' ' : text;
  final paragraphs = body.split(RegExp(r'\r?\n'));
  final xmlParagraphs = paragraphs
      .map((line) {
        final escaped = _escapeXml(line);
        return '<w:p><w:r><w:t xml:space="preserve">$escaped</w:t></w:r></w:p>';
      })
      .join();

  final documentXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:body>$xmlParagraphs<w:sectPr/></w:body></w:document>';

  const contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '</Types>';

  const rels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
      '</Relationships>';

  const documentRels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>';

  final archive = Archive()
    ..addFile(_xmlFile('[Content_Types].xml', contentTypes))
    ..addFile(_xmlFile('_rels/.rels', rels))
    ..addFile(_xmlFile('word/document.xml', documentXml))
    ..addFile(_xmlFile('word/_rels/document.xml.rels', documentRels));

  final encoded = ZipEncoder().encode(archive);
  return Uint8List.fromList(encoded);
}

ArchiveFile _xmlFile(String name, String xml) {
  final bytes = utf8.encode(xml);
  return ArchiveFile(name, bytes.length, bytes);
}

String _escapeXml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
