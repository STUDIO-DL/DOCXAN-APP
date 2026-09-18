import 'package:doxan/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatBytes usa KB para páginas típicas', () {
    expect(formatBytes(312 * 1024), '312 KB');
  });
}
