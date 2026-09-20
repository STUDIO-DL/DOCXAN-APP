import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/models/saved_document.dart';
import 'package:docxan/features/document/domain/repositories/document_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._catalog);

  final LocalLibraryCatalog _catalog;

  @override
  SavedDocument? byId(String id) => _catalog.byId(id);

  @override
  Future<void> rename(String id, String name) =>
      _catalog.renameDocument(id, name);

  @override
  Future<void> move(String id, String? folderId) =>
      _catalog.moveDocument(id, folderId);

  @override
  Future<void> toggleFavorite(String id) => _catalog.toggleFavorite(id);

  @override
  Future<void> trash(String id) => _catalog.trashDocument(id);

  @override
  Future<void> restore(String id) => _catalog.restoreDocument(id);

  @override
  Future<void> deletePermanently(String id) =>
      _catalog.deleteDocumentPermanently(id);

  @override
  Future<void> updateOcr(String id, String text) => _catalog.updateOcr(id, text);
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(ref.read(libraryCatalogProvider.notifier));
});
