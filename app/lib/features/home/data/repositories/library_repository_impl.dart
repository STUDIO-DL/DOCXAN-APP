import 'package:docxan/core/library/library_collections.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/models/saved_document.dart';
import 'package:docxan/features/home/domain/repositories/library_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._catalog);

  final List<SavedDocument> Function() _catalog;

  @override
  Future<List<SavedDocument>> recents() async {
    return _catalog();
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepositoryImpl(
    () => ref
        .read(libraryCatalogProvider)
        .inCollection(LibraryCollections.recent),
  );
});
