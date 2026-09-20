import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/library/library_collections.dart';
import 'package:doxan/core/library/local_library_catalog.dart';
import 'package:doxan/core/models/saved_folder.dart';
import 'package:doxan/core/widgets/doxan_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FoldersPage extends ConsumerStatefulWidget {
  const FoldersPage({super.key});

  @override
  ConsumerState<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends ConsumerState<FoldersPage> {
  String _query = '';

  Future<void> _createFolder() async {
    final name = await _promptName(
      title: AppLocalizations.of(context).newFolder,
      hint: AppLocalizations.of(context).createFolderHint,
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(libraryCatalogProvider.notifier).createFolder(name);
  }

  Future<String?> _promptName({
    required String title,
    required String hint,
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = ref.watch(libraryCatalogProvider);
    final q = _query.trim().toLowerCase();

    final smart = <_SmartItem>[
      _SmartItem(
        id: LibraryCollections.all,
        icon: Icons.folder_outlined,
        title: l10n.allFolders,
        count: library.inCollection(LibraryCollections.all).length,
        highlight: true,
      ),
      _SmartItem(
        id: LibraryCollections.unfiled,
        icon: Icons.folder_open_outlined,
        title: l10n.myFiles,
        count: library.inCollection(LibraryCollections.unfiled).length,
      ),
      _SmartItem(
        id: LibraryCollections.recent,
        icon: Icons.schedule,
        title: l10n.recents,
        count: library.inCollection(LibraryCollections.recent).length,
      ),
      _SmartItem(
        id: LibraryCollections.favorites,
        icon: Icons.star_outline,
        title: l10n.favorites,
        count: library.inCollection(LibraryCollections.favorites).length,
      ),
      _SmartItem(
        id: LibraryCollections.trash,
        icon: Icons.delete_outline,
        title: l10n.trash,
        count: library.inCollection(LibraryCollections.trash).length,
      ),
    ].where((item) => q.isEmpty || item.title.toLowerCase().contains(q));

    final folders = library.folders.where((folder) {
      return q.isEmpty || folder.name.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: DoxanColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            DoxanAppHeader(onProfile: () => context.go(AppRoutes.settings)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l10n.folders,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                l10n.foldersSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchFolders,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 16),
            for (final item in smart)
              _FolderRow(
                icon: item.icon,
                title: item.title,
                subtitle: l10n.documentsCount(item.count),
                highlight: item.highlight,
                onTap: () => context.push(AppRoutes.folderPath(item.id)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                l10n.quickAccess,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final folder in folders)
                    _QuickAccessTile(
                      folder: folder,
                      count: library.folderSummary(folder).documentCount,
                      onTap: () =>
                          context.push(AppRoutes.folderPath(folder.id)),
                      onLongPress: () => _folderActions(folder),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        backgroundColor: DoxanColors.ink,
        foregroundColor: DoxanColors.paper,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.newFolder),
      ),
    );
  }

  Future<void> _folderActions(SavedFolder folder) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.rename),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: DoxanColors.danger),
              title: Text(l10n.delete),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    final catalog = ref.read(libraryCatalogProvider.notifier);
    if (action == 'rename') {
      final name = await _promptName(
        title: l10n.rename,
        hint: l10n.folderName,
        initial: folder.name,
      );
      if (name != null) await catalog.renameFolder(folder.id, name);
    } else if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.confirmDelete),
          content: Text(l10n.confirmDeleteFolder),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (ok == true) await catalog.deleteFolder(folder.id);
    }
  }
}

class _SmartItem {
  const _SmartItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.count,
    this.highlight = false,
  });

  final String id;
  final IconData icon;
  final String title;
  final int count;
  final bool highlight;
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: highlight ? DoxanColors.accentSoft : DoxanColors.paper,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: DoxanColors.ink),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right, color: DoxanColors.inkMuted),
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.folder,
    required this.count,
    required this.onTap,
    required this.onLongPress,
  });

  final SavedFolder folder;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final icon = switch (folder.iconKey) {
      'universidad' => Icons.school_outlined,
      'trabajo' => Icons.work_outline,
      'otros' => Icons.more_horiz,
      'personal' => Icons.person_outline,
      _ => Icons.folder_outlined,
    };
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: DoxanColors.ink),
            const SizedBox(height: 8),
            Text(
              folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              AppLocalizations.of(context).documentsCount(count),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DoxanColors.inkMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
