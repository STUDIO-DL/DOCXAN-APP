import 'package:doxan/core/logging/app_logger.dart';
import 'package:doxan/core/ocr/ocr_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService implements OcrEngine {
  const OcrService();

  @override
  Future<String> recognize(String imagePath) => recognizeSpanish(imagePath);

  Future<String> recognizeSpanish(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(input);
      return result.text;
    } catch (error) {
      AppLogger.debug('OCR failed: $error');
      return '';
    } finally {
      await recognizer.close();
    }
  }
}

final ocrEngineProvider = Provider<OcrEngine>((ref) {
  return const OcrService();
});

