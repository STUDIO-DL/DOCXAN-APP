import 'dart:typed_data';

import 'package:doxan/core/library/library_collections.dart';
import 'package:doxan/core/library/local_library_catalog.dart';
import 'package:doxan/core/models/document_draft.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:doxan/core/storage/local_file_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MemoryLocalFileStore store;
  late ProviderContainer container;
  late LocalLibraryCatalog catalog;

  setUp(() {
    store = MemoryLocalFileStore();
    container = ProviderContainer(
      overrides: [localFileStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    catalog = container.read(libraryCatalogProvider.notifier);
  });

  DocumentDraft draft({
    String id = 'doc_1',
    String name = 'Factura',
    String ocr = 'texto ocr',
    String? folderId,
  }) {
    return DocumentDraft(
      id: id,
      name: name,
      pdfBytes: Uint8List.fromList(const [1, 2, 3, 4]),
      previewJpeg: Uint8List.fromList(const [5, 6, 7]),
      ocrText: ocr,
      pageCount: 1,
      folderId: folderId,
    );
  }

  test('mueve un documento y lo envía a la papelera', () async {
    await catalog.reload();
    expect(container.read(libraryCatalogProvider).folders, isNotEmpty);

    await catalog.write(draft());
    expect(
      container.read(libraryCatalogProvider).inCollection(LibraryCollections.unfiled),
      hasLength(1),
    );

    await catalog.moveDocument('doc_1', DefaultFolders.trabajo);
    final moved = container.read(libraryCatalogProvider).documentById('doc_1');
    expect(moved?.summary.folderId, DefaultFolders.trabajo);
    expect(moved?.summary.folderName, 'Trabajo');
    expect(
      container.read(libraryCatalogProvider).inCollection(DefaultFolders.trabajo),
      hasLength(1),
    );

    await catalog.trashDocument('doc_1');
    expect(
      container.read(libraryCatalogProvider).inCollection(LibraryCollections.trash),
      hasLength(1),
    );
    expect(
      container.read(libraryCatalogProvider).activeDocuments,
      isEmpty,
    );

    await catalog.restoreDocument('doc_1');
    expect(
      container.read(libraryCatalogProvider).documentById('doc_1')?.summary.isDeleted,
      isFalse,
    );
  });

  test('guarda cambios de OCR', () async {
    await catalog.reload();
    await catalog.write(draft(ocr: 'original'));
    await catalog.updateOcr('doc_1', 'editado por el usuario');
    expect(
      container.read(libraryCatalogProvider).documentById('doc_1')?.summary.ocrText,
      'editado por el usuario',
    );
  });

  test('purga la papelera a los 30 días', () async {
    await catalog.reload();
    await catalog.write(draft());
    final json = await store.readJson(catalogFile);
    final docs = (json!['documents'] as List).cast<Map>();
    docs.first['deletedAt'] = DateTime.now()
        .subtract(const Duration(days: 31))
        .toIso8601String();
    await store.writeJson(catalogFile, {...json, 'documents': docs});
    await catalog.reload();
    expect(container.read(libraryCatalogProvider).documents, isEmpty);
  });

  test('colecciones inteligentes: favoritos y recientes', () async {
    await catalog.reload();
    await catalog.write(draft(id: 'a', name: 'A'));
    await catalog.toggleFavorite('a');
    expect(
      LibraryCollections.filter(
        container.read(libraryCatalogProvider).documents,
        LibraryCollections.favorites,
      ),
      hasLength(1),
    );
    expect(
      LibraryCollections.filter(
        container.read(libraryCatalogProvider).documents,
        LibraryCollections.recent,
        now: DateTime.now(),
      ),
      hasLength(1),
    );
  });

  test('SavedDocument serializa carpeta nula', () {
    final restored = SavedDocument.fromJson({
      'id': 'x',
      'name': 'X',
      'folderId': 'scans',
      'ocrText': 'hola',
    });
    expect(restored.summary.folderId, isNull);
    expect(restored.summary.ocrText, 'hola');
  });
}
