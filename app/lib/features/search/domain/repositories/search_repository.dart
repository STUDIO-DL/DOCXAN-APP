import 'package:doxan/core/models/saved_document.dart';

enum SearchScope { all, recents, ocr }

abstract interface class SearchRepository {
  List<SavedDocument> search(String query, {SearchScope scope = SearchScope.all});
}
