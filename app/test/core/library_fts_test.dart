import 'package:doxan/core/database/app_database.dart';
import 'package:doxan/core/library/library_collections.dart';
import 'package:doxan/core/library/library_snapshot.dart';
import 'package:doxan/core/library/library_store.dart';
import 'package:doxan/core/models/library_models.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FTS5 encuentra por nombre, carpeta y OCR', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final store = DriftLibraryStore(db);
    final now = DateTime.now();
    await store.save(
      LibrarySnapshot(
        folders: DefaultFolders.createDefaults(now),
        documents: [
          SavedDocument(
            summary: DocumentSummary(
              id: '11111111-1111-4111-8111-aaaaaaaaaaaa',
              name: 'Factura luz',
              format: 'PDF',
              sizeBytes: 12,
              folderName: 'Personal',
              updatedAt: now,
              ocrText: 'consumo kilowatios marzo',
              folderId: DefaultFolders.personal,
            ),
            pdfPath: '/tmp/a.pdf',
            previewPath: '/tmp/a.jpg',
          ),
        ],
      ),
    );

    expect(
      await store.searchIds('Factura'),
      contains('11111111-1111-4111-8111-aaaaaaaaaaaa'),
    );
    expect(await store.searchIds('kilowatios'), isNotEmpty);
    expect(await store.searchIds('Personal'), isNotEmpty);
    expect(await store.searchIds('zzzz'), isEmpty);
  });
}
