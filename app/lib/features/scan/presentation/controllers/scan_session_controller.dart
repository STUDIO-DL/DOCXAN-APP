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
    if (state.retaking && state.pages.isNotEmpty) {
      final index = state.currentIndex.clamp(0, state.pages.length - 1);
      final pages = [...state.pages];
      final previous = pages[index];
      pages[index] = previous.copyWith(
        path: path,
        crop: crop ?? CropQuad.inset,
        rotationTurns: 0,
        filter: filter ?? previous.filter,
        brightness: previous.brightness,
        contrast: previous.contrast,
      );
      state = state.copyWith(
        pages: pages,
        currentIndex: index,
        retaking: false,
      );
      return;
    }
    final pages = [...state.pages, page];
    state = state.copyWith(pages: pages, currentIndex: pages.length - 1);
  }

  void beginRetake() {
    if (state.pages.isEmpty) return;
    state = state.copyWith(retaking: true);
  }

  void cancelRetake() {
    if (state.retaking) {
      state = state.copyWith(retaking: false);
    }
  }

  void movePage(int from, int to) {
    if (from < 0 ||
        to < 0 ||
        from >= state.pages.length ||
        to >= state.pages.length ||
        from == to) {
      return;
    }
    final pages = [...state.pages];
    final page = pages.removeAt(from);
    pages.insert(to, page);
    state = state.copyWith(pages: pages, currentIndex: to);
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
