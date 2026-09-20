import 'dart:io';

import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/export/docx_builder.dart';
import 'package:doxan/core/export/export_filenames.dart';
import 'package:doxan/core/export/image_export.dart';
import 'package:doxan/core/extensions/date_time_x.dart';
import 'package:doxan/core/library/local_library_catalog.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:doxan/core/storage/local_file_store.dart';
import 'package:doxan/core/utils/formatters.dart';
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
              color: doc.isFavorite ? DoxanColors.accent : DoxanColors.ink,
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
                color: DoxanColors.paper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DoxanColors.hairline),
              ),
              clipBehavior: Clip.antiAlias,
              child: _Preview(path: saved.previewPath),
            ),
          ),
          const SizedBox(height: 20),
          Text('${doc.format} · ${formatBytes(doc.sizeBytes)}'),
          Text('${doc.folderName} · ${doc.updatedAt.toShortDate()}'),
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
    if (files.isEmpty) return;
    await SharePlus.instance.share(ShareParams(files: files));
  }

  Future<void> _shareDocx(SavedDocument saved) async {
    final bytes = buildDocxFromText(saved.summary.ocrText);
    final name = exportFileName(saved.summary.name, 'docx');
    final path = await ref.read(localFileStoreProvider).writeCacheBytes(name, bytes);
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

class _Preview extends StatelessWidget {
  const _Preview({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final preview = path;
    if (preview != null && File(preview).existsSync()) {
      return Image.file(File(preview), fit: BoxFit.contain);
    }
    return const Center(
      child: Icon(Icons.description_outlined, size: 64),
    );
  }
}
