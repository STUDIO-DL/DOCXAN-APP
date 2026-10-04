import 'dart:async';

import 'package:docxan/core/database/app_database.dart';
import 'package:docxan/core/models/sync_status.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

enum SyncJobType { upsertMetadata, uploadBackup, deleteRemote }

class SyncJob {
  const SyncJob({
    required this.id,
    required this.type,
    required this.entityId,
    this.status = SyncStatus.pendingUpload,
    this.attempts = 0,
    this.lastError,
    this.nextRetry,
    this.payload = '{}',
  });

  final String id;
  final SyncJobType type;
  final String entityId;
  final SyncStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? nextRetry;
  final String payload;

  SyncJob copyWith({
    SyncStatus? status,
    int? attempts,
    String? lastError,
    DateTime? nextRetry,
    String? payload,
    bool clearError = false,
  }) {
    return SyncJob(
      id: id,
      type: type,
      entityId: entityId,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: clearError ? null : (lastError ?? this.lastError),
      nextRetry: nextRetry ?? this.nextRetry,
      payload: payload ?? this.payload,
    );
  }
}

DateTime syncBackoff(int attempts) {
  const delays = [0, 30, 120, 600, 1800];
  final index = attempts < delays.length ? attempts : delays.length - 1;
  return DateTime.now().add(Duration(seconds: delays[index]));
}

abstract interface class SyncQueue {
  Future<void> enqueue(SyncJob job);
  /// [ignoreBackoff]: un Sync manual reintenta ya los trabajos fallidos.
  Future<List<SyncJob>> pending({bool ignoreBackoff = false});
  Future<void> mark(String id, SyncStatus status, {String? error});
  Stream<int> pendingCount();
}

class InMemorySyncQueue implements SyncQueue {
  final _jobs = <String, SyncJob>{};
  final _pending = StreamController<int>.broadcast();

  @override
  Future<void> enqueue(SyncJob job) async {
    _jobs[job.id] = job.copyWith(
      status: SyncStatus.pendingUpload,
      nextRetry: DateTime.now(),
    );
    _pending.add(_count());
  }

  @override
  Future<List<SyncJob>> pending({bool ignoreBackoff = false}) async {
    final now = DateTime.now();
    return _jobs.values.where((job) {
      final due = ignoreBackoff ||
          job.nextRetry == null ||
          !job.nextRetry!.isAfter(now);
      return due &&
          (job.status == SyncStatus.pendingUpload ||
              job.status == SyncStatus.failed);
    }).toList();
  }

  @override
  Future<void> mark(String id, SyncStatus status, {String? error}) async {
    final current = _jobs[id];
    if (current == null) return;
    final attempts = status == SyncStatus.failed
        ? current.attempts + 1
        : current.attempts;
    _jobs[id] = current.copyWith(
      status: status,
      attempts: attempts,
      lastError: error,
      clearError: error == null,
      nextRetry: status == SyncStatus.failed
          ? syncBackoff(attempts)
          : DateTime.now(),
    );
    _pending.add(_count());
  }

  @override
  Stream<int> pendingCount() async* {
    yield _count();
    yield* _pending.stream;
  }

  int _count() {
    return _jobs.values
        .where(
          (job) =>
              job.status == SyncStatus.pendingUpload ||
              job.status == SyncStatus.failed,
        )
        .length;
  }
}

class DriftSyncQueue implements SyncQueue {
  DriftSyncQueue(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<void> enqueue(SyncJob job) async {
    final now = DateTime.now();
    await _db
        .into(_db.syncQueueItems)
        .insertOnConflictUpdate(
          SyncQueueItemsCompanion(
            id: Value(job.id.isEmpty ? _uuid.v4() : job.id),
            entityType: Value(job.type.name),
            entityId: Value(job.entityId),
            action: Value(job.type.name),
            payload: Value(job.payload),
            status: Value(SyncStatus.pendingUpload.wireName),
            attempts: Value(job.attempts),
            nextRetry: Value(job.nextRetry ?? now),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<List<SyncJob>> pending({bool ignoreBackoff = false}) async {
    final now = DateTime.now();
    final rows = await (_db.select(_db.syncQueueItems)..where(
          (row) =>
              row.status.equals(SyncStatus.pendingUpload.wireName) |
              row.status.equals(SyncStatus.failed.wireName),
        ))
        .get();
    return [
      for (final row in rows)
        if (ignoreBackoff ||
            row.nextRetry == null ||
            !row.nextRetry!.isAfter(now))
          _fromRow(row),
    ];
  }

  @override
  Future<void> mark(String id, SyncStatus status, {String? error}) async {
    final current = await (_db.select(
      _db.syncQueueItems,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (current == null) return;
    await (_db.update(
      _db.syncQueueItems,
    )..where((row) => row.id.equals(id))).write(
      SyncQueueItemsCompanion(
        status: Value(status.wireName),
        attempts: Value(
          status == SyncStatus.failed ? current.attempts + 1 : current.attempts,
        ),
        nextRetry: Value(
          status == SyncStatus.failed
              ? syncBackoff(current.attempts + 1)
              : DateTime.now(),
        ),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<int> pendingCount() {
    return _db.select(_db.syncQueueItems).watch().map((rows) {
      return rows
          .where(
            (row) =>
                row.status == SyncStatus.pendingUpload.wireName ||
                row.status == SyncStatus.failed.wireName,
          )
          .length;
    });
  }

  SyncJob _fromRow(SyncQueueRow row) {
    final type = SyncJobType.values.firstWhere(
      (item) => item.name == row.action || item.name == row.entityType,
      orElse: () => SyncJobType.upsertMetadata,
    );
    return SyncJob(
      id: row.id,
      type: type,
      entityId: row.entityId,
      status: SyncStatus.fromWire(row.status),
      attempts: row.attempts,
      lastError: row.lastError,
      nextRetry: row.nextRetry,
      payload: row.payload,
    );
  }
}

final syncQueueProvider = Provider<SyncQueue>((ref) {
  final db = ref.watch(appDatabaseProvider);
  if (db != null) return DriftSyncQueue(db);
  return InMemorySyncQueue();
});
