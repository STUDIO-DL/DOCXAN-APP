import 'package:doxan/core/models/document_draft.dart';
import 'package:doxan/core/models/saved_document.dart';

/// Scan writes through this port. Features must not import each other.
abstract interface class LibraryWriter {
  Future<SavedDocument> write(DocumentDraft draft);
}
