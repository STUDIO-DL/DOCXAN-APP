import 'package:doxan/core/library/library_snapshot.dart';
import 'package:doxan/core/models/library_models.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:doxan/features/search/data/repositories/search_repository_impl.dart';
import 'package:doxan/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SavedDocument doc({
    required String id,
    required String name,
    required String folder,
    required String ocr,
  }) {
    return SavedDocument(
      summary: DocumentSummary(
        id: id,
        name: name,
        format: 'PDF',
        sizeBytes: 10,
        folderName: folder,
        updatedAt: DateTime(2026, 9, 1),
        ocrText: ocr,
      ),
      pdfPath: '',
      previewPath: '',
    );
  }

  test('busca por nombre, carpeta y texto OCR', () {
    final repo = SearchRepositoryImpl(
      LibrarySnapshot(
        documents: [
          doc(id: '1', name: 'Factura luz', folder: 'Personal', ocr: 'IBAN'),
          doc(id: '2', name: 'Notas', folder: 'Universidad', ocr: 'examen'),
        ],
      ),
    );

    expect(repo.search('factura').single.id, '1');
    expect(repo.search('universidad').single.id, '2');
    expect(repo.search('iban').single.id, '1');
    expect(repo.search('nada'), isEmpty);
    expect(
      repo.search('examen', scope: SearchScope.ocr).single.id,
      '2',
    );
  });
}
