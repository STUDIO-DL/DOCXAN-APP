import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/features/scan/presentation/states/scan_session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanSessionController extends Notifier<ScanSessionState> {
  @override
  ScanSessionState build() => const ScanSessionState();

  void addPage(String path, {CropQuad? crop, ScanFilterKind? filter}) {
    final page = ScanSessionPage(
      id: 'page_${DateTime.now().microsecondsSinceEpoch}',
      path: path,
      crop: crop ?? CropQuad.inset,
      filter: filter ?? ScanFilterKind.document,
    );
    final pages = [...state.pages, page];
    state = state.copyWith(pages: pages, currentIndex: pages.length - 1);
  }

  void removePageAt(int index) {
    if (index < 0 || index >= state.pages.length) return;
    final pages = [...state.pages]..removeAt(index);
    final nextIndex = pages.isEmpty ? 0 : index.clamp(0, pages.length - 1);
    state = state.copyWith(pages: pages, currentIndex: nextIndex);
  }

  void setCurrentIndex(int index) {
    if (state.pages.isEmpty) return;
    state = state.copyWith(currentIndex: index.clamp(0, state.pages.length - 1));
  }

  void updateCurrent(ScanSessionPage Function(ScanSessionPage page) transform) {
    final page = state.currentPage;
    if (page == null) return;
    final index = state.currentIndex.clamp(0, state.pages.length - 1);
    final pages = [...state.pages];
    pages[index] = transform(page);
    state = state.copyWith(pages: pages, currentIndex: index);
  }

  void setCrop(CropQuad crop) => updateCurrent((page) => page.copyWith(crop: crop.clamped));

  void rotateCurrent() {
    updateCurrent(
      (page) => page.copyWith(rotationTurns: (page.rotationTurns + 1) % 4),
    );
  }

  void setFilter(ScanFilterKind filter) =>
      updateCurrent((page) => page.copyWith(filter: filter));

  void setBrightness(double value) => updateCurrent(
    (page) => page.copyWith(brightness: value.clamp(0.0, 100.0).toDouble()),
  );

  void setContrast(double value) => updateCurrent(
    (page) => page.copyWith(contrast: value.clamp(0.0, 100.0).toDouble()),
  );

  void resetCurrent() {
    updateCurrent(
      (page) => page.copyWith(
        crop: CropQuad.inset,
        rotationTurns: 0,
        filter: ScanFilterKind.document,
        brightness: 50,
        contrast: 50,
      ),
    );
  }

  void setCaptureMode(CaptureMode mode) {
    state = state.copyWith(captureMode: mode);
  }

  void setFlashOn(bool value) {
    state = state.copyWith(flashOn: value);
  }

  void clear() {
    state = const ScanSessionState();
  }
}

final scanSessionProvider =
    NotifierProvider<ScanSessionController, ScanSessionState>(
      ScanSessionController.new,
    );
