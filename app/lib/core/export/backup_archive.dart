import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:doxan/core/models/saved_document.dart';

abstract final class BackupArchive {
  static Uint8List pack(SavedDocument document) {
    final archive = Archive();
    archive.addFile(
      ArchiveFile(
        'manifest.json',
        0,
        utf8.encode(jsonEncode(document.toJson())),
      ),
    );
    _addIfExists(archive, document.pdfPath, 'document.pdf');
    for (var i = 0; i < document.pagePaths.length; i++) {
      _addIfExists(archive, document.pagePaths[i], 'pages/$i.jpg');
    }
    if (document.previewPath.isNotEmpty &&
        !document.pagePaths.contains(document.previewPath)) {
      _addIfExists(archive, document.previewPath, 'preview.jpg');
    }
    final bytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(bytes);
  }

  static SavedDocument unpack(
    List<int> zipBytes, {
    required String pdfPath,
    required String previewPath,
    required List<String> pagePaths,
  }) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      throw const FormatException('El backup no incluye manifest.json');
    }
    final json = jsonDecode(utf8.decode(manifestFile.content as List<int>));
    if (json is! Map) {
      throw const FormatException('manifest.json inválido');
    }
    return SavedDocument.fromJson(Map<String, dynamic>.from(json)).copyWith(
      pdfPath: pdfPath,
      previewPath: previewPath,
      pagePaths: pagePaths,
    );
  }

  static Map<String, List<int>> filesOf(List<int> zipBytes) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final files = <String, List<int>>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      files[file.name] = file.content as List<int>;
    }
    return files;
  }

  static void _addIfExists(Archive archive, String path, String name) {
    if (path.isEmpty) return;
    final file = File(path);
    if (!file.existsSync()) return;
    final bytes = file.readAsBytesSync();
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }
}
