import 'package:doxan/core/models/saved_document.dart';

abstract interface class LibraryRepository {
  Future<List<SavedDocument>> recents();
}
