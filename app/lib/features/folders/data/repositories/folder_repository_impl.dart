import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/models/saved_folder.dart';
import 'package:docxan/features/folders/domain/repositories/folder_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl(this._catalog);

  final LocalLibraryCatalog _catalog;

  @override
  Future<SavedFolder> createFolder(String name) => _catalog.createFolder(name);

  @override
  Future<void> renameFolder(String id, String name) =>
      _catalog.renameFolder(id, name);

  @override
  Future<void> deleteFolder(String id) => _catalog.deleteFolder(id);
}

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepositoryImpl(ref.read(libraryCatalogProvider.notifier));
});
