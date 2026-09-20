import 'package:doxan/core/imaging/crop_quad.dart';
import 'package:image/image.dart' as img;

/// Brightness/contrast are 0–100 (50 = no change).
img.Image applyBrightnessContrast(
  img.Image source, {
  required double brightness,
  required double contrast,
}) {
  final out = source.clone();
  final bOff = ((brightness - 50) / 50) * 80;
  final cFactor = contrast / 50;
  for (final pixel in out) {
    pixel
      ..r = _clamp(((pixel.r - 128) * cFactor) + 128 + bOff)
      ..g = _clamp(((pixel.g - 128) * cFactor) + 128 + bOff)
      ..b = _clamp(((pixel.b - 128) * cFactor) + 128 + bOff);
  }
  return out;
}

img.Image applyScanFilter(
  img.Image source, {
  required ScanFilterKind filter,
  required double brightness,
  required double contrast,
}) {
  switch (filter) {
    case ScanFilterKind.original:
      return applyBrightnessContrast(
        source,
        brightness: brightness,
        contrast: contrast,
      );
    case ScanFilterKind.document:
      final gray = img.grayscale(source.clone());
      return applyBrightnessContrast(
        gray,
        brightness: brightness,
        contrast: contrast < 50 ? 58 : contrast + 8,
      );
    case ScanFilterKind.bw:
      final gray = img.grayscale(source.clone());
      final boosted = applyBrightnessContrast(
        gray,
        brightness: brightness,
        contrast: 110,
      );
      final threshold = (150 - ((brightness - 50) * 1.2)).clamp(40, 220).toDouble();
      for (final pixel in boosted) {
        final v = pixel.r >= threshold ? 255 : 0;
        pixel
          ..r = v
          ..g = v
          ..b = v;
      }
      return boosted;
    case ScanFilterKind.color:
      final sat = img.adjustColor(source.clone(), saturation: 1.18);
      return applyBrightnessContrast(
        sat,
        brightness: brightness,
        contrast: contrast < 50 ? 55 : contrast + 4,
      );
  }
}

int _clamp(num value) => value.round().clamp(0, 255);
