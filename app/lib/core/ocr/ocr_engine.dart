/// Puerto de OCR. La implementación (ML Kit) vive en features/scan.
abstract interface class OcrEngine {
  Future<String> recognize(String imagePath);
}

class NoopOcrEngine implements OcrEngine {
  const NoopOcrEngine();

  @override
  Future<String> recognize(String imagePath) async => '';
}
