import 'package:doxan/core/models/saved_document.dart';

abstract interface class DocumentRepository {
  SavedDocument? byId(String id);
  Future<void> rename(String id, String name);
  Future<void> move(String id, String? folderId);
  Future<void> toggleFavorite(String id);
  Future<void> trash(String id);
  Future<void> restore(String id);
  Future<void> deletePermanently(String id);
  Future<void> updateOcr(String id, String text);
}
