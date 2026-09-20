import 'package:docxan/core/export/docx_builder.dart';
import 'package:docxan/core/export/export_filenames.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sanitizeFileName limpia caracteres reservados', () {
    expect(sanitizeFileName('  Factura: 2026/09  '), 'Factura_ 2026_09');
    expect(sanitizeFileName('???'), 'documento');
    expect(sanitizeFileName('a' * 120).length, 80);
  });

  test('exportFileName añade página si hay varias', () {
    expect(exportFileName('Informe', 'pdf'), 'Informe.pdf');
    expect(
      exportFileName('Informe', 'jpg', page: 2, pageCount: 3),
      'Informe_p2.jpg',
    );
    expect(exportFileName('Informe', '.PNG'), 'Informe.png');
  });

  test('buildDocxFromText genera un zip OOXML', () {
    final bytes = buildDocxFromText('Hola\nDocxan');
    expect(bytes.length, greaterThan(20));
    expect(bytes[0], 0x50); // P
    expect(bytes[1], 0x4b); // K
  });
}
