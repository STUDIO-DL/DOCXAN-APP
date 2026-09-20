import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/library/library_controller.dart';
import 'package:docxan/core/widgets/docxan_empty_state.dart';
import 'package:docxan/core/widgets/docxan_library_tiles.dart';
import 'package:docxan/core/widgets/docxan_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FoldersPage extends ConsumerWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final folders = ref.watch(libraryProvider).folders;
    return Scaffold(
      backgroundColor: DocxanColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            DocxanAppHeader(title: l10n.folders),
            const SizedBox(height: 20),
            DocxanSearchBar(
              hint: l10n.searchDocuments,
              onTap: () => context.go(AppRoutes.search),
            ),
            const SizedBox(height: 20),
            if (folders.isEmpty)
              DocxanEmptyState(
                icon: Icons.folder_outlined,
                title: l10n.emptyFolders,
                body: l10n.emptyFoldersBody,
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: folders.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return DocxanFolderCard(folder: folder, onTap: () {});
                },
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => showCreateFolderDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.addNewFolder),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCreateFolderDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => const _FolderNameDialog(),
  );
  if (!context.mounted || name == null) return;

  final result = ref.read(libraryProvider.notifier).createFolder(name);
  final message = switch (result) {
    FolderCreateResult.emptyName => l10n.folderNameEmpty,
    FolderCreateResult.duplicate => l10n.folderExists,
    FolderCreateResult.created => null,
  };
  if (message != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog();

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addNewFolder),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.folderName,
          hintText: l10n.folderNameHint,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _submit,
          child: Text(l10n.createFolder),
        ),
      ],
    );
  }
}
