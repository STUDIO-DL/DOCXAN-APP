import 'package:docxan/core/imaging/compression_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('perfiles de compresión exponen lado y techo JPEG', () {
    expect(CompressionProfile.small.maxSide, 2000);
    expect(CompressionProfile.balanced.maxSide, 2800);
    expect(CompressionProfile.high.maxSide, 3500);
    expect(CompressionProfile.small.maxBytes, lessThan(CompressionProfile.balanced.maxBytes));
    expect(CompressionProfile.balanced.maxBytes, lessThan(CompressionProfile.high.maxBytes));
    expect(CompressionProfile.of('small').id, 'small');
    expect(CompressionProfile.of('high').id, 'high');
    expect(CompressionProfile.of('nope').id, 'balanced');
  });
}
