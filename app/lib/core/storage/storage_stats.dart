import 'dart:io';

import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageStats {
  const StorageStats({
    required this.usedBytes,
    required this.cacheBytes,
    this.totalBytes,
  });

  final int usedBytes;
  final int cacheBytes;
  final int? totalBytes;
}

class StorageStatsService {
  StorageStatsService(this._store);

  final LocalFileStore _store;

  Future<StorageStats> load() async {
    final used = await _store.libraryBytes();
    final cache = await _store.cacheBytes();
    return StorageStats(
      usedBytes: used,
      cacheBytes: cache,
      totalBytes: await _deviceTotalBytes(),
    );
  }

  Future<void> cleanCache() => _store.clearCache();
}

Future<int?> _deviceTotalBytes() async {
  try {
    if (Platform.isAndroid) {
      final result = await Process.run('df', ['-k', '/data']);
      if (result.exitCode == 0) {
        final parsed = _parseDfKilobytes(result.stdout.toString());
        if (parsed != null) return parsed * 1024;
      }
    }
  } catch (error) {
    AppLogger.debug('Disk total unavailable: $error');
  }
  return null;
}

int? _parseDfKilobytes(String stdout) {
  final lines = stdout.trim().split(RegExp(r'\r?\n'));
  if (lines.length < 2) return null;
  final parts = lines.last.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return null;
  return int.tryParse(parts[1]);
}

final storageStatsServiceProvider = Provider<StorageStatsService>((ref) {
  return StorageStatsService(ref.watch(localFileStoreProvider));
});
