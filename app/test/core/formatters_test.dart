import 'package:docxan/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatBytes usa KB para páginas típicas', () {
    expect(formatBytes(312 * 1024), '312 KB');
  });

  test('formatRelativeTime distingue horas y ayer', () {
    final now = DateTime(2026, 9, 20, 14);
    expect(formatRelativeTime(now.subtract(const Duration(hours: 2)), now), 'Hace 2 h');
    expect(formatRelativeTime(now.subtract(const Duration(hours: 26)), now), 'Ayer');
  });
}
