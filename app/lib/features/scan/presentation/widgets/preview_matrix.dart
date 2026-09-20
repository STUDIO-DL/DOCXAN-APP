import 'package:doxan/core/imaging/crop_quad.dart';
import 'package:flutter/material.dart';

ColorFilter previewColorFilter({
  required ScanFilterKind filter,
  required double brightness,
  required double contrast,
}) {
  final b = (brightness - 50) * 2.2;
  var c = contrast / 50;
  if (filter == ScanFilterKind.document) {
    c = c < 1 ? 1.16 : c + 0.16;
  } else if (filter == ScanFilterKind.bw) {
    c = 2.1;
  } else if (filter == ScanFilterKind.color) {
    c = c < 1 ? 1.1 : c + 0.08;
  }
  final offset = 128 * (1 - c) + b;
  const r = 0.2126;
  const g = 0.7152;
  const bW = 0.0722;
  final grayscale = filter == ScanFilterKind.document || filter == ScanFilterKind.bw;

  if (grayscale) {
    return ColorFilter.matrix(<double>[
      c * r, c * g, c * bW, 0, offset,
      c * r, c * g, c * bW, 0, offset,
      c * r, c * g, c * bW, 0, offset,
      0, 0, 0, 1, 0,
    ]);
  }

  return ColorFilter.matrix(<double>[
    c, 0, 0, 0, offset,
    0, c, 0, 0, offset,
    0, 0, c, 0, offset,
    0, 0, 0, 1, 0,
  ]);
}
