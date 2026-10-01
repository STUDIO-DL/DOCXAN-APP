import 'dart:io';

import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/library/folder_labels.dart';
import 'package:docxan/core/library/library_collections.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/models/saved_document.dart';
import 'package:docxan/core/utils/formatters.dart';
import 'package:docxan/core/widgets/doxan_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FolderDetailPage extends ConsumerWidget {
  const FolderDetailPage({super.key, required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(libraryCatalogProvider);
    final docs = library.inCollection(folderId);
    final title = switch (folderId) {
      LibraryCollections.all => l10n.allFolders,
      LibraryCollections.unfiled => l10n.myFiles,
      LibraryCollections.recent => l10n.recents,
      LibraryCollections.favorites => l10n.favorites,
      LibraryCollections.trash => l10n.trash,
      _ => localizedFolderName(
          l10n,
          folderId: folderId,
          storedName: library.folderById(folderId)?.name,
        ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: docs.isEmpty
          ? DoxanEmptyState(
              icon: Icons.folder_open_outlined,
              title: l10n.emptyCollection,
              body: l10n.foldersSubtitle,
            )
          : ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return ListTile(
                  leading: _Thumb(path: doc.previewPath),
                  title: Text(doc.summary.name),
                  subtitle: Text(
                    '${doc.summary.format} · ${formatBytes(doc.summary.sizeBytes)}',
                  ),
                  trailing: folderId == LibraryCollections.trash
                      ? IconButton(
                          icon: const Icon(Icons.restore),
                          onPressed: () => ref
                              .read(libraryCatalogProvider.notifier)
                              .restoreDocument(doc.id),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.documentPath(doc.id)),
                  onLongPress: () => _docActions(context, ref, doc),
                );
              },
            ),
    );
  }

  Future<void> _docActions(
    BuildContext context,
    WidgetRef ref,
    SavedDocument doc,
  ) async {
    final l10n = AppLocalizations.of(context);
    final inTrash = doc.summary.isDeleted;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (inTrash) ...[
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l10n.restore),
                onTap: () => Navigator.pop(context, 'restore'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: DocxanColors.danger),
                title: Text(l10n.deleteForever),
                onTap: () => Navigator.pop(context, 'purge'),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.drive_file_move_outlined),
                title: Text(l10n.move),
                onTap: () => Navigator.pop(context, 'move'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: DocxanColors.danger),
                title: Text(l10n.delete),
                onTap: () => Navigator.pop(context, 'trash'),
              ),
            ],
          ],
        ),
      ),
    );
    if (action == null) return;
    final catalog = ref.read(libraryCatalogProvider.notifier);
    switch (action) {
      case 'restore':
        await catalog.restoreDocument(doc.id);
      case 'purge':
        await catalog.deleteDocumentPermanently(doc.id);
      case 'trash':
        await catalog.trashDocument(doc.id);
      case 'move':
        if (context.mounted) {
          await _moveDocument(context, ref, doc);
        }
    }
  }

  Future<void> _moveDocument(
    BuildContext context,
    WidgetRef ref,
    SavedDocument doc,
  ) async {
    final l10n = AppLocalizations.of(context);
    final folders = ref.read(libraryCatalogProvider).folders;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(l10n.noFolder),
              onTap: () => Navigator.pop(context, ''),
            ),
            for (final folder in folders)
              ListTile(
                title: Text(localizedSavedFolderName(l10n, folder)),
                onTap: () => Navigator.pop(context, folder.id),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await ref
        .read(libraryCatalogProvider.notifier)
        .moveDocument(doc.id, selected.isEmpty ? null : selected);
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final has = path.isNotEmpty && File(path).existsSync();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: DocxanColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DocxanColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: has
          ? Image.file(File(path), fit: BoxFit.cover)
          : const Icon(Icons.description_outlined),
    );
  }
}
