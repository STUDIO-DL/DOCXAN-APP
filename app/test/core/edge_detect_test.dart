import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/imaging/edge_detect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('detecta un rectángulo claro sobre fondo oscuro', () {
    final image = img.Image(width: 80, height: 80);
    for (final pixel in image) {
      pixel
        ..r = 20
        ..g = 20
        ..b = 20;
    }
    for (var y = 18; y < 62; y++) {
      for (var x = 16; x < 64; x++) {
        image.setPixelRgb(x, y, 240, 240, 240);
      }
    }
    final quad = detectDocumentQuad(image);
    expect(quad.tlX, greaterThan(0.05));
    expect(quad.tlY, greaterThan(0.05));
    expect(quad.brX, lessThan(0.95));
    expect(quad.brY, lessThan(0.95));
    expect(quad.trX, greaterThan(quad.tlX));
  });

  test('sin contraste claro usa el recorte inset', () {
    final image = img.Image(width: 40, height: 40);
    for (final pixel in image) {
      pixel
        ..r = 80
        ..g = 80
        ..b = 80;
    }
    expect(detectDocumentQuad(image), CropQuad.inset);
  });
}
