import 'dart:io';

import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/palette.dart';
import 'package:docxan/core/export/docx_builder.dart';
import 'package:docxan/core/export/export_filenames.dart';
import 'package:docxan/core/export/image_export.dart';
import 'package:docxan/core/extensions/date_time_x.dart';
import 'package:docxan/core/library/folder_labels.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/models/saved_document.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:docxan/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class DocumentPage extends ConsumerStatefulWidget {
  const DocumentPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends ConsumerState<DocumentPage> {
  final _ocr = TextEditingController();
  String? _boundId;

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  void _bindOcr(SavedDocument saved) {
    if (_boundId == saved.id) return;
    _boundId = saved.id;
    _ocr.text = saved.summary.ocrText;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(savedDocumentByIdProvider(widget.documentId));

    if (saved == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: Center(child: Text(l10n.documentNotFound)),
      );
    }

    _bindOcr(saved);
    final doc = saved.summary;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: doc.isFavorite ? l10n.unfavorite : l10n.favorite,
            onPressed: () => ref
                .read(libraryCatalogProvider.notifier)
                .toggleFavorite(saved.id),
            icon: Icon(
              doc.isFavorite ? Icons.star_rounded : Icons.star_outline,
              color: doc.isFavorite ? context.palette.accent : context.palette.ink,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: context.palette.paper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.palette.hairline),
              ),
              clipBehavior: Clip.antiAlias,
              child: _PagesPreview(paths: saved.pagePaths.isNotEmpty ? saved.pagePaths : saved.imagePaths),
            ),
          ),
          const SizedBox(height: 20),
          Text('${doc.format} · ${formatBytes(doc.sizeBytes)}'),
          Text(
            '${localizedFolderName(l10n, folderId: doc.folderId, storedName: doc.folderName)} · ${doc.updatedAt.toShortDate()}',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: Text(l10n.share),
                onPressed: () => _sharePdf(saved),
              ),
              ActionChip(
                label: Text(l10n.export),
                onPressed: () => _exportSheet(saved),
              ),
              ActionChip(
                label: Text(l10n.download),
                onPressed: () => _sharePdf(saved),
              ),
              ActionChip(
                label: Text(l10n.move),
                onPressed: () => _move(saved),
              ),
              ActionChip(
                label: Text(l10n.rename),
                onPressed: () => _rename(saved),
              ),
              ActionChip(
                label: Text(doc.isDeleted ? l10n.restore : l10n.delete),
                onPressed: () => _deleteOrRestore(saved),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.ocrText, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _ocr,
            minLines: 6,
            maxLines: 16,
            decoration: const InputDecoration(alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(libraryCatalogProvider.notifier)
                  .updateOcr(saved.id, _ocr.text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.ocrSaved)));
            },
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf(SavedDocument saved) async {
    final file = File(saved.pdfPath);
    if (!file.existsSync()) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            saved.pdfPath,
            mimeType: 'application/pdf',
            name: exportFileName(saved.summary.name, 'pdf'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSheet(SavedDocument saved) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.exportPdf),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            ListTile(
              title: Text(l10n.exportJpg),
              onTap: () => Navigator.pop(context, 'jpg'),
            ),
            ListTile(
              title: Text(l10n.exportPng),
              onTap: () => Navigator.pop(context, 'png'),
            ),
            ListTile(
              title: Text(l10n.exportWord),
              onTap: () => Navigator.pop(context, 'docx'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    switch (choice) {
      case 'pdf':
        await _sharePdf(saved);
      case 'jpg':
        await _shareImages(saved, png: false);
      case 'png':
        await _shareImages(saved, png: true);
      case 'docx':
        await _shareDocx(saved);
    }
  }

  Future<void> _shareImages(SavedDocument saved, {required bool png}) async {
    final store = ref.read(localFileStoreProvider);
    final paths = saved.imagePaths;
    if (paths.isEmpty) return;
    final files = <XFile>[];
    final temps = <String>[];
    for (var i = 0; i < paths.length; i++) {
      final source = paths[i];
      if (!File(source).existsSync()) continue;
      final page = i + 1;
      if (png) {
        final bytes = await pageAsPng(source);
        final name = exportFileName(
          saved.summary.name,
          'png',
          page: page,
          pageCount: paths.length,
        );
        final path = await store.writeCacheBytes(name, bytes);
        temps.add(path);
        files.add(XFile(path, mimeType: 'image/png', name: name));
      } else {
        files.add(
          XFile(
            source,
            mimeType: 'image/jpeg',
            name: exportFileName(
              saved.summary.name,
              'jpg',
              page: page,
              pageCount: paths.length,
            ),
          ),
        );
      }
    }
    try {
      if (files.isEmpty) return;
      await SharePlus.instance.share(ShareParams(files: files));
    } finally {
      for (final path in temps) {
        await store.deleteTempFile(path);
      }
    }
  }

  Future<void> _shareDocx(SavedDocument saved) async {
    final store = ref.read(localFileStoreProvider);
    final bytes = buildDocxFromText(saved.summary.ocrText);
    final name = exportFileName(saved.summary.name, 'docx');
    final path = await store.writeCacheBytes(name, bytes);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              path,
              mimeType:
                  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              name: name,
            ),
          ],
        ),
      );
    } finally {
      await store.deleteTempFile(path);
    }
  }

  Future<void> _rename(SavedDocument saved) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: saved.summary.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rename),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.documentName),
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
      ),
    );
    if (name == null) return;
    await ref.read(libraryCatalogProvider.notifier).renameDocument(saved.id, name);
  }

  Future<void> _move(SavedDocument saved) async {
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
                title: Text(folder.name),
                onTap: () => Navigator.pop(context, folder.id),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await ref
        .read(libraryCatalogProvider.notifier)
        .moveDocument(saved.id, selected.isEmpty ? null : selected);
  }

  Future<void> _deleteOrRestore(SavedDocument saved) async {
    final catalog = ref.read(libraryCatalogProvider.notifier);
    if (saved.summary.isDeleted) {
      await catalog.restoreDocument(saved.id);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteDocument),
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
    if (ok == true) {
      await catalog.trashDocument(saved.id);
      if (mounted) context.go(AppRoutes.home);
    }
  }
}

class _PagesPreview extends StatelessWidget {
  const _PagesPreview({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    final existing = [
      for (final path in paths)
        if (path.isNotEmpty && File(path).existsSync()) path,
    ];
    if (existing.isEmpty) {
      return const Center(
        child: Icon(Icons.description_outlined, size: 64),
      );
    }
    return PageView.builder(
      itemCount: existing.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(existing[index]), fit: BoxFit.contain),
            if (existing.length > 1)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${index + 1}/${existing.length}',
                    style: TextStyle(
                      color: context.palette.inkMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
