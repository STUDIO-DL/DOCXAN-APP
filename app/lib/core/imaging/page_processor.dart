import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:doxan/core/constants/app_constants.dart';
import 'package:doxan/core/imaging/crop_quad.dart';
import 'package:doxan/core/imaging/scan_filters.dart';
import 'package:image/image.dart' as img;

/// Top-level isolate entry. Payload keys are primitives only.
Uint8List processScanPageIsolate(Map<String, Object?> payload) {
  final path = payload['path'] as String;
  final bytes = File(path).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('No se pudo decodificar la imagen');
  }

  var work = _constrain(decoded, maxSide: 2000);
  final crop = CropQuad(
    tlX: (payload['tlX'] as num).toDouble(),
    tlY: (payload['tlY'] as num).toDouble(),
    trX: (payload['trX'] as num).toDouble(),
    trY: (payload['trY'] as num).toDouble(),
    brX: (payload['brX'] as num).toDouble(),
    brY: (payload['brY'] as num).toDouble(),
    blX: (payload['blX'] as num).toDouble(),
    blY: (payload['blY'] as num).toDouble(),
  );
  work = perspectiveCrop(work, crop);

  final turns = payload['rotationTurns'] as int? ?? 0;
  if (turns % 4 != 0) {
    work = img.copyRotate(work, angle: (turns % 4) * 90);
  }

  final filter = ScanFilterKind.values.firstWhere(
    (value) => value.name == payload['filter'],
    orElse: () => ScanFilterKind.original,
  );
  work = applyScanFilter(
    work,
    filter: filter,
    brightness: (payload['brightness'] as num?)?.toDouble() ?? 50,
    contrast: (payload['contrast'] as num?)?.toDouble() ?? 50,
  );

  return encodeDocumentJpeg(work);
}

img.Image _constrain(img.Image source, {required int maxSide}) {
  final longest = math.max(source.width, source.height);
  if (longest <= maxSide) return source;
  final scale = maxSide / longest;
  return img.copyResize(
    source,
    width: (source.width * scale).round(),
    height: (source.height * scale).round(),
  );
}

/// Bilinear mapping from a normalized quad onto a rectangle.
img.Image perspectiveCrop(img.Image source, CropQuad quad) {
  final tl = _px(source, quad.tlX, quad.tlY);
  final tr = _px(source, quad.trX, quad.trY);
  final br = _px(source, quad.brX, quad.brY);
  final bl = _px(source, quad.blX, quad.blY);

  final width = math.max(
    32,
    ((_dist(tl, tr) + _dist(bl, br)) / 2).round(),
  );
  final height = math.max(
    32,
    ((_dist(tl, bl) + _dist(tr, br)) / 2).round(),
  );

  final out = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    final v = height == 1 ? 0.0 : y / (height - 1);
    for (var x = 0; x < width; x++) {
      final u = width == 1 ? 0.0 : x / (width - 1);
      final top = _lerp(tl, tr, u);
      final bot = _lerp(bl, br, u);
      final sample = _lerp(top, bot, v);
      final sx = sample.$1.round().clamp(0, source.width - 1);
      final sy = sample.$2.round().clamp(0, source.height - 1);
      out.setPixel(x, y, source.getPixel(sx, sy));
    }
  }
  return out;
}

Uint8List encodeDocumentJpeg(img.Image image) {
  var quality = 85;
  var encoded = img.encodeJpg(image, quality: quality);
  while (encoded.length > AppConstants.targetPageBytesMax && quality > 35) {
    quality -= 10;
    encoded = img.encodeJpg(image, quality: quality);
  }
  return Uint8List.fromList(encoded);
}

(double, double) _px(img.Image source, double nx, double ny) {
  return (
    nx.clamp(0, 1) * (source.width - 1),
    ny.clamp(0, 1) * (source.height - 1),
  );
}

double _dist((double, double) a, (double, double) b) {
  final dx = a.$1 - b.$1;
  final dy = a.$2 - b.$2;
  return math.sqrt(dx * dx + dy * dy);
}

(double, double) _lerp((double, double) a, (double, double) b, double t) {
  return (a.$1 + (b.$1 - a.$1) * t, a.$2 + (b.$2 - a.$2) * t);
}
