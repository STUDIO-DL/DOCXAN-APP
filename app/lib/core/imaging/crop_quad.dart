/// Normalized document quad in image space (0–1). Order: TL, TR, BR, BL.
class CropQuad {
  const CropQuad({
    required this.tlX,
    required this.tlY,
    required this.trX,
    required this.trY,
    required this.brX,
    required this.brY,
    required this.blX,
    required this.blY,
  });

  final double tlX;
  final double tlY;
  final double trX;
  final double trY;
  final double brX;
  final double brY;
  final double blX;
  final double blY;

  static const full = CropQuad(
    tlX: 0,
    tlY: 0,
    trX: 1,
    trY: 0,
    brX: 1,
    brY: 1,
    blX: 0,
    blY: 1,
  );

  static const inset = CropQuad(
    tlX: 0.08,
    tlY: 0.08,
    trX: 0.92,
    trY: 0.08,
    brX: 0.92,
    brY: 0.92,
    blX: 0.08,
    blY: 0.92,
  );

  CropQuad copyWith({
    double? tlX,
    double? tlY,
    double? trX,
    double? trY,
    double? brX,
    double? brY,
    double? blX,
    double? blY,
  }) {
    return CropQuad(
      tlX: tlX ?? this.tlX,
      tlY: tlY ?? this.tlY,
      trX: trX ?? this.trX,
      trY: trY ?? this.trY,
      brX: brX ?? this.brX,
      brY: brY ?? this.brY,
      blX: blX ?? this.blX,
      blY: blY ?? this.blY,
    );
  }

  CropQuad get clamped {
    return CropQuad(
      tlX: tlX.clamp(0.0, 1.0).toDouble(),
      tlY: tlY.clamp(0.0, 1.0).toDouble(),
      trX: trX.clamp(0.0, 1.0).toDouble(),
      trY: trY.clamp(0.0, 1.0).toDouble(),
      brX: brX.clamp(0.0, 1.0).toDouble(),
      brY: brY.clamp(0.0, 1.0).toDouble(),
      blX: blX.clamp(0.0, 1.0).toDouble(),
      blY: blY.clamp(0.0, 1.0).toDouble(),
    );
  }

  bool similarTo(CropQuad other, [double epsilon = 0.035]) {
    return (tlX - other.tlX).abs() <= epsilon &&
        (tlY - other.tlY).abs() <= epsilon &&
        (trX - other.trX).abs() <= epsilon &&
        (trY - other.trY).abs() <= epsilon &&
        (brX - other.brX).abs() <= epsilon &&
        (brY - other.brY).abs() <= epsilon &&
        (blX - other.blX).abs() <= epsilon &&
        (blY - other.blY).abs() <= epsilon;
  }

  @override
  bool operator ==(Object other) {
    return other is CropQuad &&
        tlX == other.tlX &&
        tlY == other.tlY &&
        trX == other.trX &&
        trY == other.trY &&
        brX == other.brX &&
        brY == other.brY &&
        blX == other.blX &&
        blY == other.blY;
  }

  @override
  int get hashCode => Object.hash(tlX, tlY, trX, trY, brX, brY, blX, blY);
}

enum CropCorner { tl, tr, br, bl }

enum ScanFilterKind { original, document, bw, color }
