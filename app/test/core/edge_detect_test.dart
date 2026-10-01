import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/imaging/edge_detect.dart';
import 'package:docxan/core/imaging/page_processor.dart';
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

  test('detecta un trapecio y no un bounding box', () {
    final image = img.Image(width: 100, height: 100);
    for (final pixel in image) {
      pixel
        ..r = 12
        ..g = 12
        ..b = 12;
    }
    for (var y = 18; y < 82; y++) {
      final t = (y - 18) / 64;
      final left = (28 - 12 * t).round();
      final right = (72 + 12 * t).round();
      for (var x = left; x <= right; x++) {
        image.setPixelRgb(x, y, 245, 245, 245);
      }
    }
    final quad = detectDocumentQuad(image);
    expect(quad, isNot(CropQuad.inset));
    expect(quad.blX, lessThan(quad.tlX - 0.02));
    expect(quad.brX, greaterThan(quad.trX + 0.02));
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

  test('perspectiveCrop endereza un quad y usa bilinear', () {
    final source = img.Image(width: 40, height: 40);
    for (final pixel in source) {
      pixel
        ..r = 0
        ..g = 0
        ..b = 0;
    }
    for (var y = 5; y < 35; y++) {
      for (var x = 8; x < 32; x++) {
        source.setPixelRgb(x, y, 200, 200, 200);
      }
    }
    source.setPixelRgb(8, 5, 255, 0, 0);
    final out = perspectiveCrop(
      source,
      const CropQuad(
        tlX: 8 / 39,
        tlY: 5 / 39,
        trX: 31 / 39,
        trY: 5 / 39,
        brX: 31 / 39,
        brY: 34 / 39,
        blX: 8 / 39,
        blY: 34 / 39,
      ),
    );
    expect(out.width, greaterThan(10));
    expect(out.height, greaterThan(10));
    final corner = out.getPixel(0, 0);
    expect(corner.r, greaterThan(corner.g));
  });

  test('bilinear interpola entre píxeles en vez de nearest-neighbor', () {
    final source = img.Image(width: 2, height: 2);
    source.setPixelRgb(0, 0, 0, 0, 0);
    source.setPixelRgb(1, 0, 255, 0, 0);
    source.setPixelRgb(0, 1, 0, 0, 0);
    source.setPixelRgb(1, 1, 255, 0, 0);
    final out = perspectiveCrop(source, CropQuad.full);
    final mid = out.getPixel(out.width ~/ 2, 0);
    expect(mid.r, greaterThan(40));
    expect(mid.r, lessThan(220));
  });
}
