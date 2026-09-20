import 'package:docxan/core/library/library_collections.dart';
import 'package:docxan/core/library/library_snapshot.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/models/saved_document.dart';
import 'package:docxan/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._library);

  final LibrarySnapshot _library;

  @override
  List<SavedDocument> search(
    String query, {
    SearchScope scope = SearchScope.all,
  }) {
    final q = query.trim().toLowerCase();
    var docs = switch (scope) {
      SearchScope.recents => _library.inCollection(LibraryCollections.recent),
      SearchScope.all || SearchScope.ocr => _library.activeDocuments,
    };
    if (q.isEmpty) {
      return scope == SearchScope.all ? const [] : docs;
    }
    return docs.where((doc) {
      final matchesQuery =
          doc.summary.name.toLowerCase().contains(q) ||
          doc.summary.folderName.toLowerCase().contains(q) ||
          doc.summary.ocrText.toLowerCase().contains(q);
      if (!matchesQuery) return false;
      if (scope == SearchScope.ocr) {
        return doc.summary.ocrText.trim().isNotEmpty;
      }
      return true;
    }).toList();
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(ref.watch(libraryCatalogProvider));
});
