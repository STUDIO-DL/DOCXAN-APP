import 'package:docxan/core/database/app_database.dart';
import 'package:docxan/core/models/profile.dart';
import 'package:docxan/core/sync/remote_metadata_client.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ProfileRepository {
  Future<Profile?> byId(String id);
  Future<void> upsert(Profile profile);
}

class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository(this._db, this._remote);

  final AppDatabase? _db;
  final RemoteMetadataClient _remote;

  @override
  Future<Profile?> byId(String id) async {
    final db = _db;
    if (db == null) return null;
    final row = await (db.select(
      db.profiles,
    )..where((item) => item.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Profile(
      id: row.id,
      email: row.email,
      displayName: row.displayName,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> upsert(Profile profile) async {
    final now = DateTime.now();
    final db = _db;
    if (db != null) {
      await db
          .into(db.profiles)
          .insertOnConflictUpdate(
            ProfilesCompanion(
              id: Value(profile.id),
              email: Value(profile.email),
              displayName: Value(profile.displayName),
              createdAt: Value(profile.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );
    }
    await _remote.upsertProfile(profile.copyWith(updatedAt: now));
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return LocalProfileRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(remoteMetadataClientProvider),
  );
});
