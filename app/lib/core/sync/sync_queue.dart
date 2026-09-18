enum SyncJobType { upsertMetadata, uploadBackup, deleteRemote }

class SyncJob {
  const SyncJob({required this.id, required this.type});

  final String id;
  final SyncJobType type;
}

/// Cola offline-first. WorkManager se engancha aquí en la semana 2.
abstract interface class SyncQueue {
  Future<void> enqueue(SyncJob job);
  Stream<int> pendingCount();
}

class InMemorySyncQueue implements SyncQueue {
  final _jobs = <SyncJob>[];

  @override
  Future<void> enqueue(SyncJob job) async => _jobs.add(job);

  @override
  Stream<int> pendingCount() => Stream<int>.value(_jobs.length);
}
