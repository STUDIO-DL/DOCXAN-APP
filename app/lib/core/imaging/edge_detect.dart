import 'dart:io';
import 'dart:math' as math;

import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:image/image.dart' as img;

/// Finds a document quadrilateral (not just an axis-aligned box).
CropQuad detectDocumentQuad(img.Image source) {
  final work = _downscale(source, 320);
  final width = work.width;
  final height = work.height;
  if (width < 12 || height < 12) return CropQuad.inset;

  final count = width * height;
  final lum = List<double>.filled(count, 0);
  var sum = 0.0;
  var minL = 255.0;
  var maxL = 0.0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = work.getPixel(x, y);
      final value = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      lum[y * width + x] = value;
      sum += value;
      if (value < minL) minL = value;
      if (value > maxL) maxL = value;
    }
  }
  if (maxL - minL < 28) return CropQuad.inset;

  final blurred = _boxBlur(lum, width, height);
  final mean = sum / count;
  var threshold = math.min(220.0, math.max(mean + 16, minL + 40));

  var mask = _paperMask(lum, blurred, width, height, threshold);
  var paper = _countTrue(mask);
  var area = paper / count;
  if (area > 0.86) {
    threshold = math.min(235.0, threshold + 22);
    mask = _paperMask(lum, blurred, width, height, threshold);
    paper = _countTrue(mask);
    area = paper / count;
  }
  if (paper < 40 || area < 0.10 || area > 0.94) {
    final fromEdges = _quadFromGradient(lum, width, height);
    return fromEdges ?? CropQuad.inset;
  }

  final blob = _largestBlob(mask, width, height);
  final corners = _extremes(blob.mask, width, height);
  if (corners == null) return CropQuad.inset;

  var quad = CropQuad(
    tlX: corners.tlX / (width - 1),
    tlY: corners.tlY / (height - 1),
    trX: corners.trX / (width - 1),
    trY: corners.trY / (height - 1),
    brX: corners.brX / (width - 1),
    brY: corners.brY / (height - 1),
    blX: corners.blX / (width - 1),
    blY: corners.blY / (height - 1),
  ).clamped;

  if (!_isValidQuad(quad)) {
    final box = blob.bounds;
    final padX = math.max(1, ((box.$3 - box.$1) * 0.03).round());
    final padY = math.max(1, ((box.$4 - box.$2) * 0.03).round());
    quad = CropQuad(
      tlX: (box.$1 + padX) / (width - 1),
      tlY: (box.$2 + padY) / (height - 1),
      trX: (box.$3 - padX) / (width - 1),
      trY: (box.$2 + padY) / (height - 1),
      brX: (box.$3 - padX) / (width - 1),
      brY: (box.$4 - padY) / (height - 1),
      blX: (box.$1 + padX) / (width - 1),
      blY: (box.$4 - padY) / (height - 1),
    ).clamped;
  }

  return _isValidQuad(quad) ? _insetQuad(quad, 0.012) : CropQuad.inset;
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

List<bool> _paperMask(
  List<double> lum,
  List<double> blurred,
  int width,
  int height,
  double threshold,
) {
  final mask = List<bool>.filled(width * height, false);
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      final i = y * width + x;
      final adaptive = math.max(threshold, blurred[i] + 8);
      if (lum[i] >= adaptive) mask[i] = true;
    }
  }
  return mask;
}

int _countTrue(List<bool> mask) {
  var n = 0;
  for (final bit in mask) {
    if (bit) n++;
  }
  return n;
}

class _Blob {
  const _Blob(this.mask, this.bounds);
  final List<bool> mask;
  final (int, int, int, int) bounds;
}

_Blob _largestBlob(List<bool> mask, int width, int height) {
  final count = width * height;
  final parent = List<int>.generate(count, (i) => i);

  int find(int x) {
    var root = x;
    while (parent[root] != root) {
      root = parent[root];
    }
    var cursor = x;
    while (parent[cursor] != cursor) {
      final next = parent[cursor];
      parent[cursor] = root;
      cursor = next;
    }
    return root;
  }

  void unite(int a, int b) {
    final ra = find(a);
    final rb = find(b);
    if (ra != rb) parent[ra] = rb;
  }

  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      final i = y * width + x;
      if (!mask[i]) continue;
      if (x + 1 < width - 1 && mask[i + 1]) unite(i, i + 1);
      if (y + 1 < height - 1 && mask[i + width]) unite(i, i + width);
    }
  }

  final sizes = <int, int>{};
  for (var i = 0; i < count; i++) {
    if (!mask[i]) continue;
    final root = find(i);
    sizes[root] = (sizes[root] ?? 0) + 1;
  }
  var best = -1;
  var bestSize = 0;
  sizes.forEach((root, size) {
    if (size > bestSize) {
      bestSize = size;
      best = root;
    }
  });

  final kept = List<bool>.filled(count, false);
  var minX = width, minY = height, maxX = -1, maxY = -1;
  if (best >= 0) {
    for (var i = 0; i < count; i++) {
      if (!mask[i] || find(i) != best) continue;
      kept[i] = true;
      final x = i % width;
      final y = i ~/ width;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }
  return _Blob(kept, (minX, minY, maxX, maxY));
}

class _Corners {
  const _Corners({
    required this.tlX,
    required this.tlY,
    required this.trX,
    required this.trY,
    required this.brX,
    required this.brY,
    required this.blX,
    required this.blY,
  });

  final int tlX, tlY, trX, trY, brX, brY, blX, blY;
}

_Corners? _extremes(List<bool> mask, int width, int height) {
  var minSum = 1e9;
  var maxSum = -1e9;
  var minDiff = 1e9;
  var maxDiff = -1e9;
  var tlX = 0, tlY = 0, trX = 0, trY = 0, brX = 0, brY = 0, blX = 0, blY = 0;
  var found = false;
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      if (!mask[y * width + x]) continue;
      found = true;
      final s = x + y;
      final d = x - y;
      if (s < minSum) {
        minSum = s.toDouble();
        tlX = x;
        tlY = y;
      }
      if (s > maxSum) {
        maxSum = s.toDouble();
        brX = x;
        brY = y;
      }
      if (d > maxDiff) {
        maxDiff = d.toDouble();
        trX = x;
        trY = y;
      }
      if (d < minDiff) {
        minDiff = d.toDouble();
        blX = x;
        blY = y;
      }
    }
  }
  if (!found) return null;
  return _Corners(
    tlX: tlX,
    tlY: tlY,
    trX: trX,
    trY: trY,
    brX: brX,
    brY: brY,
    blX: blX,
    blY: blY,
  );
}

CropQuad? _quadFromGradient(List<double> lum, int width, int height) {
  final mag = List<double>.filled(width * height, 0);
  var maxMag = 0.0;
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      final i = y * width + x;
      final gx = -lum[i - width - 1] -
          2 * lum[i - 1] -
          lum[i + width - 1] +
          lum[i - width + 1] +
          2 * lum[i + 1] +
          lum[i + width + 1];
      final gy = -lum[i - width - 1] -
          2 * lum[i - width] -
          lum[i - width + 1] +
          lum[i + width - 1] +
          2 * lum[i + width] +
          lum[i + width + 1];
      final value = gx.abs() + gy.abs();
      mag[i] = value;
      if (value > maxMag) maxMag = value;
    }
  }
  if (maxMag < 40) return null;
  final cut = maxMag * 0.28;
  final edges = List<bool>.filled(width * height, false);
  var n = 0;
  for (var i = 0; i < mag.length; i++) {
    if (mag[i] >= cut) {
      edges[i] = true;
      n++;
    }
  }
  if (n < 40) return null;
  final blob = _largestBlob(edges, width, height);
  final corners = _extremes(blob.mask, width, height);
  if (corners == null) return null;
  final quad = CropQuad(
    tlX: corners.tlX / (width - 1),
    tlY: corners.tlY / (height - 1),
    trX: corners.trX / (width - 1),
    trY: corners.trY / (height - 1),
    brX: corners.brX / (width - 1),
    brY: corners.brY / (height - 1),
    blX: corners.blX / (width - 1),
    blY: corners.blY / (height - 1),
  ).clamped;
  return _isValidQuad(quad) ? _insetQuad(quad, 0.012) : null;
}

img.Image _downscale(img.Image source, int maxSide) {
  final longest = math.max(source.width, source.height);
  if (longest <= maxSide) return source;
  final scale = maxSide / longest;
  return img.copyResize(
    source,
    width: math.max(24, (source.width * scale).round()),
    height: math.max(24, (source.height * scale).round()),
  );
}

List<double> _boxBlur(List<double> lum, int width, int height) {
  final tmp = List<double>.from(lum);
  final out = List<double>.from(lum);
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      var acc = 0.0;
      for (var ky = -1; ky <= 1; ky++) {
        for (var kx = -1; kx <= 1; kx++) {
          acc += lum[(y + ky) * width + (x + kx)];
        }
      }
      tmp[y * width + x] = acc / 9;
    }
  }
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      var acc = 0.0;
      for (var ky = -1; ky <= 1; ky++) {
        for (var kx = -1; kx <= 1; kx++) {
          acc += tmp[(y + ky) * width + (x + kx)];
        }
      }
      out[y * width + x] = acc / 9;
    }
  }
  return out;
}

bool _isValidQuad(CropQuad quad) {
  final widthTop = (quad.trX - quad.tlX).abs();
  final widthBot = (quad.brX - quad.blX).abs();
  final heightL = (quad.blY - quad.tlY).abs();
  final heightR = (quad.brY - quad.trY).abs();
  if (widthTop < 0.18 || widthBot < 0.18) return false;
  if (heightL < 0.18 || heightR < 0.18) return false;
  if (quad.tlX > quad.trX || quad.blX > quad.brX) return false;
  if (quad.tlY > quad.blY || quad.trY > quad.brY) return false;
  return true;
}

CropQuad _insetQuad(CropQuad quad, double amount) {
  final cx = (quad.tlX + quad.trX + quad.brX + quad.blX) / 4;
  final cy = (quad.tlY + quad.trY + quad.brY + quad.blY) / 4;
  (double, double) pull(double x, double y) {
    return (x + (cx - x) * amount, y + (cy - y) * amount);
  }

  final tl = pull(quad.tlX, quad.tlY);
  final tr = pull(quad.trX, quad.trY);
  final br = pull(quad.brX, quad.brY);
  final bl = pull(quad.blX, quad.blY);
  return CropQuad(
    tlX: tl.$1,
    tlY: tl.$2,
    trX: tr.$1,
    trY: tr.$2,
    brX: br.$1,
    brY: br.$2,
    blX: bl.$1,
    blY: bl.$2,
  ).clamped;
}
