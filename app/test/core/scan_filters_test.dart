import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/imaging/scan_filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('original 50/50 deja el pixel igual', () {
    final source = img.Image(width: 1, height: 1);
    source.setPixelRgb(0, 0, 200, 40, 10);
    final out = applyScanFilter(
      source,
      filter: ScanFilterKind.original,
      brightness: 50,
      contrast: 50,
    );
    final pixel = out.getPixel(0, 0);
    expect(pixel.r, 200);
    expect(pixel.g, 40);
    expect(pixel.b, 10);
  });

  test('documento convierte un pixel de color a gris', () {
    final source = img.Image(width: 1, height: 1);
    source.setPixelRgb(0, 0, 255, 0, 0);
    final out = applyScanFilter(
      source,
      filter: ScanFilterKind.document,
      brightness: 50,
      contrast: 50,
    );
    final pixel = out.getPixel(0, 0);
    expect(pixel.r, pixel.g);
    expect(pixel.g, pixel.b);
  });

  test('brillo 100 aclara un gris medio', () {
    final source = img.Image(width: 1, height: 1);
    source.setPixelRgb(0, 0, 120, 120, 120);
    final out = applyBrightnessContrast(
      source,
      brightness: 100,
      contrast: 50,
    );
    expect(out.getPixel(0, 0).r, greaterThan(120));
  });
}
