import 'package:docxan/core/imaging/crop_quad.dart';

class ScanSessionPage {
  const ScanSessionPage({
    required this.id,
    required this.path,
    this.crop = CropQuad.inset,
    this.rotationTurns = 0,
    this.filter = ScanFilterKind.document,
    this.brightness = 50,
    this.contrast = 50,
  });

  final String id;
  final String path;
  final CropQuad crop;
  final int rotationTurns;
  final ScanFilterKind filter;
  final double brightness;
  final double contrast;

  ScanSessionPage copyWith({
    String? id,
    String? path,
    CropQuad? crop,
    int? rotationTurns,
    ScanFilterKind? filter,
    double? brightness,
    double? contrast,
  }) {
    return ScanSessionPage(
      id: id ?? this.id,
      path: path ?? this.path,
      crop: crop ?? this.crop,
      rotationTurns: rotationTurns ?? this.rotationTurns,
      filter: filter ?? this.filter,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
    );
  }

  Map<String, Object?> toProcessMap({
    int? maxSide,
    int? maxBytes,
  }) => {
    'path': path,
    'tlX': crop.tlX,
    'tlY': crop.tlY,
    'trX': crop.trX,
    'trY': crop.trY,
    'brX': crop.brX,
    'brY': crop.brY,
    'blX': crop.blX,
    'blY': crop.blY,
    'rotationTurns': rotationTurns,
    'filter': filter.name,
    'brightness': brightness,
    'contrast': contrast,
    if (maxSide != null) 'maxSide': maxSide,
    if (maxBytes != null) 'maxBytes': maxBytes,
  };
}

enum CaptureMode { auto, manual }

class ScanSessionState {
  const ScanSessionState({
    this.pages = const [],
    this.currentIndex = 0,
    this.captureMode = CaptureMode.auto,
    this.flashOn = false,
    this.retaking = false,
  });

  final List<ScanSessionPage> pages;
  final int currentIndex;
  final CaptureMode captureMode;
  final bool flashOn;
  final bool retaking;

  int get pageCount => pages.length;

  ScanSessionPage? get currentPage {
    if (pages.isEmpty) return null;
    final index = currentIndex.clamp(0, pages.length - 1);
    return pages[index];
  }

  ScanSessionState copyWith({
    List<ScanSessionPage>? pages,
    int? currentIndex,
    CaptureMode? captureMode,
    bool? flashOn,
    bool? retaking,
  }) {
    return ScanSessionState(
      pages: pages ?? this.pages,
      currentIndex: currentIndex ?? this.currentIndex,
      captureMode: captureMode ?? this.captureMode,
      flashOn: flashOn ?? this.flashOn,
      retaking: retaking ?? this.retaking,
    );
  }
}
