abstract interface class SearchRepository {
  Future<List<Object>> search(String query);
}
