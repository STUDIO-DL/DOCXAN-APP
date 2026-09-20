import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:docxan/core/database/tables.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Profiles, Folders, Documents, DocumentPages, SyncQueueItems, UserSettingsItems],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await _createFts();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await _try(migrator.addColumn(folders, folders.iconKey));
          await _try(migrator.addColumn(documents, documents.compressionProfile));
          await _try(migrator.addColumn(documents, documents.contentHash));
          await _try(migrator.createTable(documentPages));
          await _try(
            customStatement('ALTER TABLE sync_queue_items RENAME TO sync_jobs'),
          );
          await _try(migrator.addColumn(syncQueueItems, syncQueueItems.payload));
          await _try(migrator.addColumn(syncQueueItems, syncQueueItems.nextRetry));
        }
        await _createFts();
      },
    );
  }

  Future<void> _createFts() async {
    await customStatement('''
CREATE VIRTUAL TABLE IF NOT EXISTS document_fts USING fts5(
  document_id UNINDEXED,
  name,
  folder_name,
  ocr_text,
  tokenize = 'unicode61'
)
''');
  }

  Future<void> rebuildDocumentFts({
    required String documentId,
    required String name,
    required String folderName,
    required String ocrText,
  }) async {
    await customStatement(
      'DELETE FROM document_fts WHERE document_id = ?',
      [documentId],
    );
    await customStatement(
      'INSERT INTO document_fts(document_id, name, folder_name, ocr_text) '
      'VALUES (?, ?, ?, ?)',
      [documentId, name, folderName, ocrText],
    );
  }

  Future<void> deleteDocumentFts(String documentId) async {
    await customStatement(
      'DELETE FROM document_fts WHERE document_id = ?',
      [documentId],
    );
  }

  Future<List<String>> searchFts(String query) async {
    final token = _ftsQuery(query);
    if (token == null) return const [];
    try {
      final rows = await customSelect(
        'SELECT document_id FROM document_fts WHERE document_fts MATCH ?',
        variables: [Variable.withString(token)],
      ).get();
      return [
        for (final row in rows) row.read<String>('document_id'),
      ];
    } catch (error) {
      AppLogger.debug('FTS search skipped: $error');
      return const [];
    }
  }

  static String? _ftsQuery(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'[^\wáéíóúüñÁÉÍÓÚÜÑ\s]+', unicode: true), ' ')
        .trim();
    if (cleaned.isEmpty) return null;
    return cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '$part*')
        .join(' AND ');
  }

  Future<void> _try(Future<void> action) async {
    try {
      await action;
    } catch (error) {
      AppLogger.debug('Drift migrate step skipped: $error');
    }
  }

  static Future<AppDatabase> open() async {
    try {
      return AppDatabase();
    } catch (error) {
      AppLogger.debug('Drift open failed, using memory: $error');
      return AppDatabase.memory();
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'docxan.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase?>((ref) => null);
