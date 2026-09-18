/// Archivos locales: páginas temporales, PDFs, blobs cifrados.
abstract interface class LocalFileStore {
  Future<String> documentsDir();
}

class MemoryLocalFileStore implements LocalFileStore {
  const MemoryLocalFileStore();

  @override
  Future<String> documentsDir() async => 'local://documents';
}
