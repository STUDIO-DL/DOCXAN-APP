import 'dart:math' as math;

import 'package:docxan/core/imaging/crop_quad.dart';
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
      return unsharpMask(
        applyBrightnessContrast(
          source,
          brightness: brightness,
          contrast: contrast,
        ),
        amount: 0.35,
      );
    case ScanFilterKind.document:
      final gray = img.grayscale(source.clone());
      final flat = flattenIllumination(gray);
      final stretched = stretchContrast(flat);
      final whitened = whitenPaper(stretched);
      final tuned = applyBrightnessContrast(
        whitened,
        brightness: brightness,
        contrast: contrast < 50 ? 56 : contrast + 6,
      );
      return unsharpMask(tuned, amount: 0.55);
    case ScanFilterKind.bw:
      final gray = img.grayscale(source.clone());
      final flat = flattenIllumination(gray);
      final binary = adaptiveThreshold(
        flat,
        brightness: brightness,
      );
      return applyBrightnessContrast(
        binary,
        brightness: 50,
        contrast: contrast < 50 ? 50 : math.min(100, contrast),
      );
    case ScanFilterKind.color:
      final flat = flattenIllumination(source.clone());
      final stretched = stretchContrast(flat);
      final whitened = whitenPaper(stretched, keepColor: true);
      final sat = img.adjustColor(whitened, saturation: 1.12);
      return unsharpMask(
        applyBrightnessContrast(
          sat,
          brightness: brightness,
          contrast: contrast < 50 ? 54 : contrast + 4,
        ),
        amount: 0.45,
      );
  }
}

img.Image flattenIllumination(img.Image source) {
  if (source.width < 16 || source.height < 16) return source;
  final w = math.max(8, source.width ~/ 16);
  final h = math.max(8, source.height ~/ 16);
  var bg = img.copyResize(source, width: w, height: h);
  bg = img.gaussianBlur(bg, radius: 2);
  bg = img.copyResize(bg, width: source.width, height: source.height);
  final out = source.clone();
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final s = source.getPixel(x, y);
      final b = bg.getPixel(x, y);
      out.setPixelRgb(
        x,
        y,
        _clamp(s.r * 255 / math.max(b.r, 18) * 0.92),
        _clamp(s.g * 255 / math.max(b.g, 18) * 0.92),
        _clamp(s.b * 255 / math.max(b.b, 18) * 0.92),
      );
    }
  }
  return out;
}

img.Image stretchContrast(img.Image source) {
  final samples = <int>[];
  final step = math.max(1, (source.width * source.height) ~/ 4000);
  var i = 0;
  for (final pixel in source) {
    if (i % step == 0) {
      samples.add(((pixel.r + pixel.g + pixel.b) / 3).round());
    }
    i++;
  }
  samples.sort();
  if (samples.length < 8) return source;
  final lo = samples[(samples.length * 0.02).floor()].toDouble();
  final hi = samples[(samples.length * 0.98).floor()].toDouble();
  final span = math.max(18.0, hi - lo);
  final out = source.clone();
  for (final pixel in out) {
    pixel
      ..r = _clamp((pixel.r - lo) * 255 / span)
      ..g = _clamp((pixel.g - lo) * 255 / span)
      ..b = _clamp((pixel.b - lo) * 255 / span);
  }
  return out;
}

img.Image whitenPaper(img.Image source, {bool keepColor = false}) {
  final out = source.clone();
  for (final pixel in out) {
    final luma = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
    if (luma < 168) continue;
    final t = ((luma - 168) / 87).clamp(0.0, 1.0);
    final lift = 255 * t * t;
    if (keepColor) {
      pixel
        ..r = _clamp(pixel.r + lift * 0.65)
        ..g = _clamp(pixel.g + lift * 0.65)
        ..b = _clamp(pixel.b + lift * 0.65);
    } else {
      final v = _clamp(luma + lift);
      pixel
        ..r = v
        ..g = v
        ..b = v;
    }
  }
  return out;
}

img.Image adaptiveThreshold(
  img.Image source, {
  required double brightness,
}) {
  var mean = img.copyResize(
    source,
    width: math.max(8, source.width ~/ 12),
    height: math.max(8, source.height ~/ 12),
  );
  mean = img.gaussianBlur(mean, radius: 2);
  mean = img.copyResize(mean, width: source.width, height: source.height);
  final bias = ((brightness - 50) / 50) * 18;
  final out = source.clone();
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final s = source.getPixel(x, y).r;
      final m = mean.getPixel(x, y).r;
      final v = s >= (m * 0.90 - 6 + bias) ? 255 : 0;
      out.setPixelRgb(x, y, v, v, v);
    }
  }
  return out;
}

img.Image unsharpMask(img.Image source, {double amount = 0.5}) {
  if (source.width < 4 || source.height < 4 || amount <= 0) return source;
  final blur = img.gaussianBlur(source.clone(), radius: 1);
  final out = source.clone();
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final s = source.getPixel(x, y);
      final b = blur.getPixel(x, y);
      out.setPixelRgb(
        x,
        y,
        _clamp(s.r + amount * (s.r - b.r)),
        _clamp(s.g + amount * (s.g - b.g)),
        _clamp(s.b + amount * (s.b - b.b)),
      );
    }
  }
  return out;
}

int _clamp(num value) => value.round().clamp(0, 255);
