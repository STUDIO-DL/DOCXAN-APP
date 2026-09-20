import 'package:docxan/core/models/saved_folder.dart';

abstract interface class FolderRepository {
  Future<SavedFolder> createFolder(String name);
  Future<void> renameFolder(String id, String name);
  Future<void> deleteFolder(String id);
}
