import 'package:camera/camera.dart';
import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/imaging/edge_detect.dart';
import 'package:image/image.dart' as img;

CropQuad detectDocumentQuadFromCamera(CameraImage image) {
  final plane = image.planes.first;
  final width = image.width;
  final height = image.height;
  final bytes = plane.bytes;
  final stride = plane.bytesPerRow;
  if (width < 8 || height < 8) return CropQuad.inset;

  final gray = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    final row = y * stride;
    for (var x = 0; x < width; x++) {
      final luma = bytes[row + x];
      gray.setPixelRgb(x, y, luma, luma, luma);
    }
  }
  return detectDocumentQuad(gray);
}

bool isDocumentDetected(CropQuad quad) => quad != CropQuad.inset;
