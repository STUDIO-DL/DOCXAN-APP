abstract interface class DocumentRepository {
  Future<void> rename(String id, String name);
  Future<void> delete(String id);
}
