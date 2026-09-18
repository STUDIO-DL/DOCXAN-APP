import 'package:doxan/core/models/library_models.dart';

abstract final class DemoCatalog {
  static final folders = <FolderSummary>[
    FolderSummary(
      id: 'personal',
      name: 'Personal',
      documentCount: 1,
      updatedAt: DateTime(2026, 9, 12),
    ),
    FolderSummary(
      id: 'universidad',
      name: 'Universidad',
      documentCount: 1,
      updatedAt: DateTime(2026, 9, 10),
    ),
    FolderSummary(
      id: 'trabajo',
      name: 'Trabajo',
      documentCount: 1,
      updatedAt: DateTime(2026, 9, 8),
    ),
  ];

  static final documents = <DocumentSummary>[
    DocumentSummary(
      id: 'passport',
      name: 'Pasaporte',
      format: 'PDF',
      sizeBytes: 624 * 1024,
      folderId: 'personal',
      folderName: 'Personal',
      updatedAt: DateTime(2026, 9, 12),
      ocrText: 'Pasaporte Reino de España número P1234567 Universidad',
      isDemo: true,
    ),
    DocumentSummary(
      id: 'certificate',
      name: 'Certificado Universidad',
      format: 'PDF',
      sizeBytes: 312 * 1024,
      folderId: 'universidad',
      folderName: 'Universidad',
      updatedAt: DateTime(2026, 9, 10),
      ocrText: 'Certificado de estudios Universidad de ejemplo curso 2025',
      isDemo: true,
    ),
    DocumentSummary(
      id: 'invoice',
      name: 'Factura',
      format: 'PDF',
      sizeBytes: 198 * 1024,
      folderId: 'trabajo',
      folderName: 'Trabajo',
      updatedAt: DateTime(2026, 9, 8),
      ocrText: 'Factura servicios profesionales IVA 21%',
      isDemo: true,
    ),
  ];

  static DocumentSummary? documentById(String id) {
    for (final doc in documents) {
      if (doc.id == id) return doc;
    }
    return null;
  }
}
