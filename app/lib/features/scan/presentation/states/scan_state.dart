enum ScanPhase { idle, capturing, enhancing, ocr, ready }

class ScanState {
  const ScanState({this.phase = ScanPhase.idle, this.pageCount = 0});

  final ScanPhase phase;
  final int pageCount;
}
