import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:docxan/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final localFileStoreProvider = Provider<LocalFileStore>((ref) {
  return PathLocalFileStore();
});

/// Archivos locales: páginas temporales, PDFs, catálogo.
abstract interface class LocalFileStore {
  Future<String> documentsDir();
  Future<String> writeBytes(String relativePath, List<int> bytes);
  Future<String> writeCacheBytes(String name, List<int> bytes);
  Future<String> copyToCache(String sourcePath, String name);
  Future<Map<String, dynamic>?> readJson(String relativePath);
  Future<void> writeJson(String relativePath, Map<String, dynamic> data);
  Future<void> deleteRelative(String relativePath);
  Future<void> deleteDocumentDir(String documentId);
  Future<int> libraryBytes();
  Future<int> cacheBytes();
  Future<void> clearCache();

  /// Deletes [path] only if it lives in the app temp/cache dirs (our scan
  /// cache, camera or image_picker copies). Never throws.
  Future<void> deleteTempFile(String path);

  /// Deletes plaintext leftovers: files in our scan cache modified before
  /// [scanCutoff], and known plugin temps (camera `CAP*`, image_picker,
  /// share_plus copies) modified before [pluginCutoff]. Paths in [keep] are
  /// never touched. Never throws.
  Future<void> sweepTemps({
    required DateTime scanCutoff,
    required DateTime pluginCutoff,
    Set<String> keep = const {},
  });
}

class MemoryLocalFileStore implements LocalFileStore {
  MemoryLocalFileStore();

  final Map<String, List<int>> files = {};

  @override
  Future<String> documentsDir() async => 'local://documents';

  @override
  Future<String> writeBytes(String relativePath, List<int> bytes) async {
    files[relativePath] = List<int>.from(bytes);
    return 'local://documents/$relativePath';
  }

  @override
  Future<String> writeCacheBytes(String name, List<int> bytes) async {
    files['cache/$name'] = List<int>.from(bytes);
    return 'local://cache/$name';
  }

  @override
  Future<String> copyToCache(String sourcePath, String name) async {
    files['cache/$name'] = List<int>.from(files[sourcePath] ?? const []);
    return 'local://cache/$name';
  }

  @override
  Future<Map<String, dynamic>?> readJson(String relativePath) async {
    final raw = files[relativePath];
    if (raw == null) return null;
    return jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
  }

  @override
  Future<void> writeJson(String relativePath, Map<String, dynamic> data) async {
    files[relativePath] = utf8.encode(jsonEncode(data));
  }

  @override
  Future<void> deleteRelative(String relativePath) async {
    files.remove(relativePath);
  }

  @override
  Future<void> deleteDocumentDir(String documentId) async {
    final prefix = '$documentId/';
    files.removeWhere((key, _) => key == documentId || key.startsWith(prefix));
  }

  @override
  Future<int> libraryBytes() async {
    var total = 0;
    for (final entry in files.entries) {
      if (!entry.key.startsWith('cache/')) {
        total += entry.value.length;
      }
    }
    return total;
  }

  @override
  Future<int> cacheBytes() async {
    var total = 0;
    for (final entry in files.entries) {
      if (entry.key.startsWith('cache/')) {
        total += entry.value.length;
      }
    }
    return total;
  }

  @override
  Future<void> clearCache() async {
    files.removeWhere((key, _) => key.startsWith('cache/'));
  }

  @override
  Future<void> deleteTempFile(String path) async {
    final key = _cacheKey(path);
    if (key != null) files.remove(key);
  }

  /// No timestamps in memory: removes every cache entry not in [keep].
  @override
  Future<void> sweepTemps({
    required DateTime scanCutoff,
    required DateTime pluginCutoff,
    Set<String> keep = const {},
  }) async {
    final kept = keep.map(_cacheKey).whereType<String>().toSet();
    files.removeWhere(
      (key, _) => key.startsWith('cache/') && !kept.contains(key),
    );
  }

  static String? _cacheKey(String path) {
    const scheme = 'local://';
    final key = path.startsWith(scheme) ? path.substring(scheme.length) : path;
    return key.startsWith('cache/') ? key : null;
  }
}

class PathLocalFileStore implements LocalFileStore {
  @override
  Future<String> documentsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'library'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> _cacheDir() async {
    final tmp = await getTemporaryDirectory();
    return p.join(tmp.path, 'docxan_scan');
  }

  @override
  Future<String> writeBytes(String relativePath, List<int> bytes) async {
    final file = File(p.join(await documentsDir(), relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<String> writeCacheBytes(String name, List<int> bytes) async {
    final file = File(p.join(await _cacheDir(), name));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<String> copyToCache(String sourcePath, String name) async {
    final dest = File(p.join(await _cacheDir(), name));
    await dest.parent.create(recursive: true);
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }

  @override
  Future<Map<String, dynamic>?> readJson(String relativePath) async {
    final file = File(p.join(await documentsDir(), relativePath));
    if (!await file.exists()) return null;
    return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  }

  @override
  Future<void> writeJson(String relativePath, Map<String, dynamic> data) async {
    final file = File(p.join(await documentsDir(), relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  @override
  Future<void> deleteRelative(String relativePath) async {
    final file = File(p.join(await documentsDir(), relativePath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteDocumentDir(String documentId) async {
    final dir = Directory(p.join(await documentsDir(), documentId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  Future<int> libraryBytes() async {
    return _directorySize(Directory(await documentsDir()));
  }

  @override
  Future<int> cacheBytes() async {
    return _directorySize(Directory(await _cacheDir()));
  }

  @override
  Future<void> clearCache() async {
    final dir = Directory(await _cacheDir());
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);
  }

  static const _scanDirName = 'docxan_scan';
  static const _pluginPrefixes = ['CAP', 'image_picker', 'scaled_'];

  @override
  Future<void> deleteTempFile(String path) async {
    try {
      final target = p.normalize(File(path).absolute.path);
      final roots = await _tempRoots();
      if (!roots.any((root) => p.isWithin(root, target))) return;
      final file = File(target);
      if (await file.exists()) await file.delete();
    } catch (error) {
      AppLogger.debug('Temp delete skipped: $error');
    }
  }

  @override
  Future<void> sweepTemps({
    required DateTime scanCutoff,
    required DateTime pluginCutoff,
    Set<String> keep = const {},
  }) async {
    try {
      final kept = keep.map((path) => p.normalize(path)).toSet();
      for (final root in await _tempRoots()) {
        await _sweepDir(
          Directory(p.join(root, _scanDirName)),
          cutoff: scanCutoff,
          keep: kept,
          recursive: true,
        );
        await _sweepDir(
          Directory(p.join(root, 'share_plus')),
          cutoff: pluginCutoff,
          keep: kept,
          recursive: true,
        );
        await _sweepDir(
          Directory(root),
          cutoff: pluginCutoff,
          keep: kept,
          prefixes: _pluginPrefixes,
        );
        await _sweepDir(
          Directory(p.join(root, 'pictures')),
          cutoff: pluginCutoff,
          keep: kept,
          prefixes: _pluginPrefixes,
        );
      }
    } catch (error) {
      AppLogger.debug('Temp sweep skipped: $error');
    }
  }

  /// App-private temp roots. Shallow paths (e.g. `/tmp` on a dev machine)
  /// are ignored so we never sweep a shared system directory.
  Future<List<String>> _tempRoots() async {
    final roots = <String>{};
    try {
      roots.add(p.normalize((await getTemporaryDirectory()).path));
    } catch (_) {}
    try {
      roots.add(p.normalize(Directory.systemTemp.path));
    } catch (_) {}
    return roots
        .where((root) => p.split(root).where((s) => s != p.separator).length >= 3)
        .toList();
  }

  Future<void> _sweepDir(
    Directory dir, {
    required DateTime cutoff,
    required Set<String> keep,
    bool recursive = false,
    List<String>? prefixes,
  }) async {
    try {
      if (!await dir.exists()) return;
      final stale = <File>[];
      await for (final entity in dir.list(
        recursive: recursive,
        followLinks: false,
      )) {
        if (entity is! File) continue;
        final path = p.normalize(entity.path);
        if (keep.contains(path)) continue;
        if (prefixes != null) {
          final name = p.basename(path);
          if (!prefixes.any((prefix) => name.startsWith(prefix))) continue;
        }
        try {
          if ((await entity.lastModified()).isBefore(cutoff)) {
            stale.add(entity);
          }
        } catch (_) {}
      }
      for (final file in stale) {
        try {
          await file.delete();
        } catch (_) {}
      }
    } catch (error) {
      AppLogger.debug('Temp sweep of ${dir.path} skipped: $error');
    }
  }
}

Future<int> _directorySize(Directory dir) async {
  if (!await dir.exists()) return 0;
  var total = 0;
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      total += await entity.length();
    }
  }
  return total;
}

/// Convenience for callers that already have JPEG bytes.
extension LocalFileStoreBytes on LocalFileStore {
  Future<String> writeTypedBytes(String relativePath, Uint8List bytes) {
    return writeBytes(relativePath, bytes);
  }
}
