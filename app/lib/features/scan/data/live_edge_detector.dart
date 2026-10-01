import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/imaging/edge_detect.dart';
import 'package:image/image.dart' as img;

CropQuad detectDocumentQuadFromCamera(CameraImage image) {
  final plane = image.planes.first;
  final width = image.width;
  final height = image.height;
  final bytes = plane.bytes;
  final stride = plane.bytesPerRow;
  if (width < 16 || height < 16) return CropQuad.inset;

  final bgra = image.format.group == ImageFormatGroup.bgra8888;
  final step = math.max(1, math.max(width, height) ~/ 320);
  final outW = math.max(24, width ~/ step);
  final outH = math.max(24, height ~/ step);
  final gray = img.Image(width: outW, height: outH);
  for (var y = 0; y < outH; y++) {
    final srcY = (y * step).clamp(0, height - 1);
    final row = srcY * stride;
    for (var x = 0; x < outW; x++) {
      final srcX = (x * step).clamp(0, width - 1);
      var luma = 0;
      if (bgra) {
        final index = row + srcX * 4;
        if (index + 2 < bytes.length) {
          final b = bytes[index];
          final g = bytes[index + 1];
          final r = bytes[index + 2];
          luma = (0.299 * r + 0.587 * g + 0.114 * b).round();
        }
      } else {
        final index = row + srcX;
        luma = index < bytes.length ? bytes[index] : 0;
      }
      gray.setPixelRgb(x, y, luma, luma, luma);
    }
  }
  return detectDocumentQuad(gray);
}

bool isDocumentDetected(CropQuad quad) => quad != CropQuad.inset;
