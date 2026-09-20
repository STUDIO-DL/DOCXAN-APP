import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

Uint8List encodePngFromJpegBytes(Uint8List jpeg) {
  final decoded = img.decodeImage(jpeg);
  if (decoded == null) {
    throw StateError('No se pudo decodificar la imagen');
  }
  return Uint8List.fromList(img.encodePng(decoded));
}

Future<Uint8List> readPageBytes(String path) async {
  return File(path).readAsBytes();
}

Future<Uint8List> pageAsPng(String jpegPath) async {
  final bytes = await readPageBytes(jpegPath);
  return encodePngFromJpegBytes(bytes);
}
