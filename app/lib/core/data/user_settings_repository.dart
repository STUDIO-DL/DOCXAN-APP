import 'package:doxan/core/database/app_database.dart';
import 'package:doxan/core/models/user_settings.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/core/sync/remote_metadata_client.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class UserSettingsRepository {
  Future<UserSettings> load();
  Future<void> save(UserSettings settings);
}

class LocalUserSettingsRepository implements UserSettingsRepository {
  LocalUserSettingsRepository(this._db, this._remote, this._userId);

  final AppDatabase? _db;
  final RemoteMetadataClient _remote;
  final String _userId;

  @override
  Future<UserSettings> load() async {
    final db = _db;
    if (db == null) return const UserSettings();
    final row = await (db.select(
      db.userSettingsItems,
    )..where((item) => item.id.equals(_userId))).getSingleOrNull();
    if (row == null) return const UserSettings();
    return UserSettings(
      compressionProfile: row.compressionProfile,
      backupEnabled: row.backupEnabled,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> save(UserSettings settings) async {
    final now = DateTime.now();
    final db = _db;
    if (db != null) {
      await db
          .into(db.userSettingsItems)
          .insertOnConflictUpdate(
            UserSettingsItemsCompanion(
              id: Value(_userId),
              compressionProfile: Value(settings.compressionProfile),
              backupEnabled: Value(settings.backupEnabled),
              updatedAt: Value(now),
            ),
          );
    }
    if (_userId != 'local') {
      await _remote.upsertSettings(
        userId: _userId,
        settings: settings.copyWith(updatedAt: now),
      );
    }
  }
}

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  final session = ref.watch(sessionProvider);
  return LocalUserSettingsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(remoteMetadataClientProvider),
    session.userId ?? 'local',
  );
});
