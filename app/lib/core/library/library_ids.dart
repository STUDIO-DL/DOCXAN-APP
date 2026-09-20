import 'package:uuid/uuid.dart';

abstract final class LibraryIds {
  static const _uuid = Uuid();
  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isUuid(String id) => _uuidPattern.hasMatch(id);

  static String newId() => _uuid.v4();

  /// Stable remote PK so local string IDs can upsert into Postgres uuid columns.
  static String remoteUuid(String localId) {
    if (isUuid(localId)) return localId;
    return _uuid.v5(
      '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
      'https://docxan.app/id/$localId',
    );
  }
}
