import 'package:drift/drift.dart';

@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FolderRow')
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text().withDefault(const Constant('folder'))();
  TextColumn get parentId => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DocumentRow')
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get format => text().withDefault(const Constant('PDF'))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get folderId => text().nullable()();
  TextColumn get folderName =>
      text().withDefault(const Constant('Mis archivos'))();
  TextColumn get ocrText => text().withDefault(const Constant(''))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get pdfPath => text().withDefault(const Constant(''))();
  TextColumn get previewPath => text().withDefault(const Constant(''))();
  IntColumn get pageCount => integer().withDefault(const Constant(1))();
  TextColumn get pagePathsJson => text().withDefault(const Constant('[]'))();
  TextColumn get compressionProfile =>
      text().withDefault(const Constant('balanced'))();
  TextColumn get contentHash => text().withDefault(const Constant(''))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PageRow')
class DocumentPages extends Table {
  @override
  String get tableName => 'pages';

  TextColumn get id => text()();
  TextColumn get documentId => text()();
  IntColumn get pageIndex => integer()();
  TextColumn get localPath => text()();
  TextColumn get cropQuadJson => text().nullable()();
  IntColumn get rotation => integer().withDefault(const Constant(0))();
  TextColumn get filterId => text().withDefault(const Constant('original'))();
  IntColumn get brightness => integer().withDefault(const Constant(50))();
  IntColumn get contrast => integer().withDefault(const Constant(50))();
  IntColumn get width => integer().withDefault(const Constant(0))();
  IntColumn get height => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SyncQueueRow')
class SyncQueueItems extends Table {
  @override
  String get tableName => 'sync_jobs';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get status => text().withDefault(const Constant('pending_upload'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetry => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserSettingsRow')
class UserSettingsItems extends Table {
  TextColumn get id => text()();
  TextColumn get compressionProfile =>
      text().withDefault(const Constant('balanced'))();
  BoolColumn get backupEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
