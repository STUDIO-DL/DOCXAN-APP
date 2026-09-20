import 'package:doxan/core/constants/app_constants.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:doxan/core/models/saved_folder.dart';

abstract final class DefaultFolders {
  static const personal = '11111111-1111-4111-8111-000000000001';
  static const universidad = '22222222-2222-4222-8222-000000000002';
  static const trabajo = '33333333-3333-4333-8333-000000000003';
  static const otros = '44444444-4444-4444-8444-000000000004';

  static const legacyIds = <String, String>{
    'personal': personal,
    'universidad': universidad,
    'trabajo': trabajo,
    'otros': otros,
    'scans': '',
  };

  static const seed = <(String, String, String)>[
    (personal, 'Personal', 'personal'),
    (universidad, 'Universidad', 'universidad'),
    (trabajo, 'Trabajo', 'trabajo'),
    (otros, 'Otros', 'otros'),
  ];

  static String canonicalize(String id) => legacyIds[id] ?? id;

  static String? canonicalizeNullable(String? id) {
    if (id == null || id.isEmpty) return null;
    final mapped = canonicalize(id);
    return mapped.isEmpty ? null : mapped;
  }

  static String iconKeyFor(String id) {
    final canonical = canonicalize(id);
    if (canonical == personal) return 'personal';
    if (canonical == universidad) return 'universidad';
    if (canonical == trabajo) return 'trabajo';
    if (canonical == otros) return 'otros';
    return 'folder';
  }

  static List<SavedFolder> createDefaults([DateTime? now]) {
    final stamp = now ?? DateTime.now();
    return [
      for (final item in seed)
        SavedFolder(
          id: item.$1,
          name: item.$2,
          updatedAt: stamp,
          isDefault: true,
          iconKey: item.$3,
        ),
    ];
  }
}

abstract final class LibraryCollections {
  static const all = 'all';
  static const unfiled = 'unfiled';
  static const recent = 'recent';
  static const favorites = 'favorites';
  static const trash = 'trash';

  static const smartIds = {all, unfiled, recent, favorites, trash};

  static bool isSmart(String id) => smartIds.contains(id);

  static List<SavedDocument> filter(
    List<SavedDocument> documents,
    String collectionId, {
    DateTime? now,
    Duration recentWindow = const Duration(days: 14),
  }) {
    final clock = now ?? DateTime.now();
    switch (collectionId) {
      case all:
        return documents.where((doc) => !doc.summary.isDeleted).toList();
      case unfiled:
        return documents
            .where(
              (doc) =>
                  !doc.summary.isDeleted &&
                  (doc.summary.folderId == null ||
                      doc.summary.folderId!.isEmpty),
            )
            .toList();
      case recent:
        final cutoff = clock.subtract(recentWindow);
        final active = documents
            .where(
              (doc) =>
                  !doc.summary.isDeleted &&
                  doc.summary.updatedAt.isAfter(cutoff),
            )
            .toList();
        active.sort(
          (a, b) => b.summary.updatedAt.compareTo(a.summary.updatedAt),
        );
        return active;
      case favorites:
        return documents
            .where((doc) => !doc.summary.isDeleted && doc.summary.isFavorite)
            .toList();
      case trash:
        return documents.where((doc) => doc.summary.isDeleted).toList();
      default:
        return documents
            .where(
              (doc) =>
                  !doc.summary.isDeleted &&
                  doc.summary.folderId == collectionId,
            )
            .toList();
    }
  }

  static bool shouldPurge(SavedDocument document, {DateTime? now}) {
    final deletedAt = document.summary.deletedAt;
    if (deletedAt == null) return false;
    final clock = now ?? DateTime.now();
    return clock.difference(deletedAt) >=
        const Duration(days: AppConstants.trashRetentionDays);
  }

  static String folderDisplayName({
    required String? folderId,
    required List<SavedFolder> folders,
    String unfiledLabel = 'Mis archivos',
  }) {
    if (folderId == null || folderId.isEmpty) return unfiledLabel;
    for (final folder in folders) {
      if (folder.id == folderId) return folder.name;
    }
    return unfiledLabel;
  }
}
