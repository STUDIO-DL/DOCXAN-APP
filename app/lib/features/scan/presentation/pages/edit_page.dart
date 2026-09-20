import 'dart:io';

import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/features/scan/data/scan_export_service.dart';
import 'package:docxan/features/scan/presentation/controllers/scan_session_controller.dart';
import 'package:docxan/features/scan/presentation/states/scan_session_state.dart';
import 'package:docxan/features/scan/presentation/widgets/crop_overlay.dart';
import 'package:docxan/features/scan/presentation/widgets/preview_matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _EditorTool { crop, rotate, brightness, contrast }

class EditPage extends ConsumerStatefulWidget {
  const EditPage({super.key});

  @override
  ConsumerState<EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
  _EditorTool _tool = _EditorTool.crop;
  bool _saving = false;
  String _savePhase = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(scanSessionProvider).pages.isEmpty) {
        context.go(AppRoutes.scanCapture);
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final session = ref.read(scanSessionProvider);
    if (session.pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noPagesToSave)),
      );
      return;
    }
    setState(() {
      _saving = true;
      _savePhase = l10n.savingDocument;
    });
    try {
      final draft = await ref.read(scanExportProvider).export(
        session,
        onProgress: (phase) {
          if (!mounted) return;
          setState(() {
            _savePhase = phase == 'ocr'
                ? l10n.recognizingText
                : l10n.savingDocument;
          });
        },
      );
      final saved = await ref.read(libraryWriterProvider).write(draft);
      ref.read(scanSessionProvider.notifier).clear();
      if (!mounted) return;
      if (draft.ocrText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ocrUnavailable)),
        );
      }
      context.go(AppRoutes.documentPath(saved.id));
    } catch (error) {
      AppLogger.debug('Save failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.saveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(scanSessionProvider);
    final page = session.currentPage;
    final controller = ref.read(scanSessionProvider.notifier);

    return Scaffold(
      backgroundColor: DocxanColors.paper,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Text(
                          l10n.editDocument,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: page == null ? null : controller.resetCurrent,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3.1,
                        child: page == null
                            ? const SizedBox.shrink()
                            : _PagePreview(page: page),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _ToolButton(
                            icon: Icons.crop_outlined,
                            label: l10n.crop,
                            selected: _tool == _EditorTool.crop,
                            onTap: () =>
                                setState(() => _tool = _EditorTool.crop),
                          ),
                          _ToolButton(
                            icon: Icons.rotate_right,
                            label: l10n.rotate,
                            selected: _tool == _EditorTool.rotate,
                            onTap: () {
                              setState(() => _tool = _EditorTool.rotate);
                              controller.rotateCurrent();
                            },
                          ),
                          _ToolButton(
                            icon: Icons.wb_sunny_outlined,
                            label: l10n.brightness,
                            selected: _tool == _EditorTool.brightness,
                            onTap: () => setState(
                              () => _tool = _EditorTool.brightness,
                            ),
                          ),
                          _ToolButton(
                            icon: Icons.contrast,
                            label: l10n.contrast,
                            selected: _tool == _EditorTool.contrast,
                            onTap: () => setState(
                              () => _tool = _EditorTool.contrast,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.filters,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (page != null)
                        _FilterRow(
                          page: page,
                          onSelected: controller.setFilter,
                        ),
                      const SizedBox(height: 16),
                      _LabeledSlider(
                        icon: Icons.wb_sunny_outlined,
                        label: l10n.brightness,
                        value: page?.brightness ?? 50,
                        onChanged: controller.setBrightness,
                      ),
                      _LabeledSlider(
                        icon: Icons.contrast,
                        label: l10n.contrast,
                        value: page?.contrast ?? 50,
                        onChanged: controller.setContrast,
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: DocxanColors.accentSoft,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => context.go(AppRoutes.scanCapture),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: DocxanColors.accent,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.addAnotherPage,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        l10n.addAnotherPageSubtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: DocxanColors.inkMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.saveDocument),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            const ModalBarrier(dismissible: false, color: Color(0x66000000)),
          if (_saving)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: DocxanColors.accent,
                      ),
                      const SizedBox(width: 16),
                      Text(_savePhase),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PagePreview extends ConsumerWidget {
  const _PagePreview({required this.page});

  final ScanSessionPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = File(page.path);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DocxanColors.canvas,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: RotatedBox(
          quarterTurns: page.rotationTurns,
          child: _SizedPreview(file: file, page: page),
        ),
      ),
    );
  }
}

class _SizedPreview extends ConsumerStatefulWidget {
  const _SizedPreview({required this.file, required this.page});

  final File file;
  final ScanSessionPage page;

  @override
  ConsumerState<_SizedPreview> createState() => _SizedPreviewState();
}

class _SizedPreviewState extends ConsumerState<_SizedPreview> {
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _resolveSize();
  }

  @override
  void didUpdateWidget(covariant _SizedPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _resolveSize();
    }
  }

  Future<void> _resolveSize() async {
    try {
      final bytes = await widget.file.readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      if (!mounted) return;
      setState(() {
        _imageSize = Size(
          decoded.width.toDouble(),
          decoded.height.toDouble(),
        );
      });
    } catch (_) {
      if (mounted) {
        setState(() => _imageSize = const Size(3, 4));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _imageSize ?? const Size(3, 4);
    final page = widget.page;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: previewColorFilter(
              filter: page.filter,
              brightness: page.brightness,
              contrast: page.contrast,
            ),
            child: Image.file(widget.file, fit: BoxFit.fill),
          ),
          CropOverlay(
            quad: page.crop,
            onChanged: (quad) {
              ref.read(scanSessionProvider.notifier).setCrop(quad);
            },
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? DocxanColors.accentSoft : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? DocxanColors.accent : DocxanColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? DocxanColors.ink : DocxanColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.page, required this.onSelected});

  final ScanSessionPage page;
  final ValueChanged<ScanFilterKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(ScanFilterKind, String)>[
      (ScanFilterKind.original, l10n.filterOriginal),
      (ScanFilterKind.document, l10n.filterDocument),
      (ScanFilterKind.bw, l10n.filterBw),
      (ScanFilterKind.color, l10n.filterColor),
    ];
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _FilterThumb(
                page: page,
                kind: item.$1,
                label: item.$2,
                selected: page.filter == item.$1,
                onTap: () => onSelected(item.$1),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterThumb extends StatelessWidget {
  const _FilterThumb({
    required this.page,
    required this.kind,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ScanSessionPage page;
  final ScanFilterKind kind;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? DocxanColors.accent : DocxanColors.hairline,
                width: selected ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ColorFiltered(
              colorFilter: previewColorFilter(
                filter: kind,
                brightness: page.brightness,
                contrast: page.contrast,
              ),
              child: Image.file(File(page.path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: DocxanColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DocxanColors.ink),
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: 100,
              value: value,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${value.round()}%',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
