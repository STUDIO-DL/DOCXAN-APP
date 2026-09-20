import 'package:doxan/core/models/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsea los estados de sync del wire format', () {
    expect(SyncStatus.fromWire('local_only'), SyncStatus.localOnly);
    expect(SyncStatus.fromWire('pending_upload'), SyncStatus.pendingUpload);
    expect(SyncStatus.fromWire('uploading'), SyncStatus.uploading);
    expect(SyncStatus.fromWire('synced'), SyncStatus.synced);
    expect(SyncStatus.fromWire('failed'), SyncStatus.failed);
    expect(SyncStatus.pendingUpload.wireName, 'pending_upload');
  });
}
