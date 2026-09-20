import 'dart:io';
import 'dart:math' as math;

import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:image/image.dart' as img;

/// Lightweight paper-vs-desk heuristic. Falls back to [CropQuad.inset].
CropQuad detectDocumentQuad(img.Image source) {
  final longest = math.max(source.width, source.height);
  final work = longest > 160
      ? img.copyResize(
          source,
          width: source.width > source.height
              ? 160
              : (160 * source.width / source.height).round().clamp(24, 160),
          height: source.height >= source.width
              ? 160
              : (160 * source.height / source.width).round().clamp(24, 160),
        )
      : source;

  final width = work.width;
  final height = work.height;
  if (width < 8 || height < 8) return CropQuad.inset;

  final lum = List<double>.filled(width * height, 0);
  var sum = 0.0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = work.getPixel(x, y);
      final value = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b);
      lum[y * width + x] = value;
      sum += value;
    }
  }
  final mean = sum / lum.length;
  final threshold = math.min(220.0, math.max(mean + 18, 140));

  var minX = width;
  var minY = height;
  var maxX = -1;
  var maxY = -1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (lum[y * width + x] >= threshold) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (maxX < minX || maxY < minY) return CropQuad.inset;

  final boxW = maxX - minX + 1;
  final boxH = maxY - minY + 1;
  final area = (boxW * boxH) / (width * height);
  if (area < 0.12 || area > 0.96) return CropQuad.inset;

  final padX = math.max(1, (boxW * 0.04).round());
  final padY = math.max(1, (boxH * 0.04).round());
  final left = (minX + padX) / (width - 1);
  final top = (minY + padY) / (height - 1);
  final right = (maxX - padX) / (width - 1);
  final bottom = (maxY - padY) / (height - 1);

  if (right - left < 0.2 || bottom - top < 0.2) return CropQuad.inset;

  return CropQuad(
    tlX: left,
    tlY: top,
    trX: right,
    trY: top,
    brX: right,
    brY: bottom,
    blX: left,
    blY: bottom,
  ).clamped;
}

CropQuad detectDocumentQuadFromFile(String path) {
  try {
    final bytes = File(path).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return CropQuad.inset;
    return detectDocumentQuad(decoded);
  } catch (error) {
    AppLogger.debug('Auto-crop fallback: $error');
    return CropQuad.inset;
  }
}
