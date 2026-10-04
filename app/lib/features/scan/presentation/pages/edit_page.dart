import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/palette.dart';
import 'package:docxan/core/data/user_settings_repository.dart';
import 'package:docxan/core/extensions/date_time_x.dart';
import 'package:docxan/core/imaging/compression_profile.dart';
import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/core/imaging/page_processor.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/features/scan/data/scan_export_service.dart';
import 'package:docxan/features/scan/presentation/controllers/scan_session_controller.dart';
import 'package:docxan/features/scan/presentation/states/scan_session_state.dart';
import 'package:docxan/features/scan/presentation/widgets/crop_overlay.dart';
import 'package:docxan/features/scan/presentation/widgets/preview_matrix.dart';
import 'package:flutter/foundation.dart';
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
      final settings = await ref.read(userSettingsRepositoryProvider).load();
      final draft = await ref.read(scanExportProvider).export(
        session,
        documentName: l10n.documentNamed(DateTime.now().toShortDate()),
        profile: CompressionProfile.of(settings.compressionProfile),
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
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.paper,
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
                            : _PagePreview(
                                page: page,
                                showCrop: _tool == _EditorTool.crop,
                              ),
                      ),
                      if (session.pages.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _PageStrip(
                          pages: session.pages,
                          currentIndex: session.currentIndex,
                          onSelect: controller.setCurrentIndex,
                          onReorder: controller.movePage,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: page == null
                                  ? null
                                  : () {
                                      controller.beginRetake();
                                      context.go(AppRoutes.scanCapture);
                                    },
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: Text(l10n.retakePage),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: l10n.delete,
                            onPressed: page == null
                                ? null
                                : () {
                                    controller.removePageAt(
                                      session.currentIndex,
                                    );
                                    if (ref
                                        .read(scanSessionProvider)
                                        .pages
                                        .isEmpty) {
                                      context.go(AppRoutes.scanCapture);
                                    }
                                  },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
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
                        color: palette.accentSoft,
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
                                Icon(
                                  Icons.add,
                                  color: palette.accent,
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
                                Icon(
                                  Icons.chevron_right,
                                  color: palette.inkMuted,
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
                      CircularProgressIndicator(
                        color: palette.accent,
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

class _PageStrip extends StatelessWidget {
  const _PageStrip({
    required this.pages,
    required this.currentIndex,
    required this.onSelect,
    required this.onReorder,
  });

  final List<ScanSessionPage> pages;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final void Function(int from, int to) onReorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        onReorder: (from, to) {
          final dest = to > from ? to - 1 : to;
          onReorder(from, dest);
        },
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final selected = index == currentIndex;
          return ReorderableDelayedDragStartListener(
            key: ValueKey(pages[index].id),
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? context.palette.accent
                          : context.palette.hairline,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    File(pages[index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PagePreview extends ConsumerWidget {
  const _PagePreview({required this.page, required this.showCrop});

  final ScanSessionPage page;
  final bool showCrop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = File(page.path);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.canvas,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: RotatedBox(
          quarterTurns: showCrop ? page.rotationTurns : 0,
          child: _SizedPreview(
            file: file,
            page: page,
            showCrop: showCrop,
          ),
        ),
      ),
    );
  }
}

class _SizedPreview extends ConsumerStatefulWidget {
  const _SizedPreview({
    required this.file,
    required this.page,
    required this.showCrop,
  });

  final File file;
  final ScanSessionPage page;
  final bool showCrop;

  @override
  ConsumerState<_SizedPreview> createState() => _SizedPreviewState();
}

class _SizedPreviewState extends ConsumerState<_SizedPreview> {
  Size? _imageSize;
  Uint8List? _processed;
  Object? _job;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _resolveSize();
    _scheduleProcess();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SizedPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _processed = null;
      _resolveSize();
    }
    if (oldWidget.file.path != widget.file.path ||
        oldWidget.page.crop != widget.page.crop ||
        oldWidget.page.filter != widget.page.filter ||
        oldWidget.page.brightness != widget.page.brightness ||
        oldWidget.page.contrast != widget.page.contrast ||
        oldWidget.page.rotationTurns != widget.page.rotationTurns ||
        oldWidget.showCrop != widget.showCrop) {
      _scheduleProcess();
    }
  }

  void _scheduleProcess() {
    if (widget.showCrop) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), _process);
  }

  Future<void> _process() async {
    if (widget.showCrop) return;
    final job = Object();
    _job = job;
    try {
      final bytes = await compute(
        processScanPageIsolate,
        widget.page.toProcessMap(maxSide: 960, maxBytes: 280 * 1024),
      );
      if (!mounted || _job != job) return;
      setState(() => _processed = bytes);
    } catch (_) {}
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
    final processed = _processed;
    if (!widget.showCrop && processed != null) {
      return Image.memory(processed, fit: BoxFit.contain);
    }
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
          if (widget.showCrop)
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
    final palette = context.palette;
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
                  color: selected ? palette.accentSoft : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? palette.accent : palette.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? palette.ink : palette.inkMuted,
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
                color: selected ? context.palette.accent : context.palette.hairline,
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
              color: context.palette.ink,
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
          Icon(icon, size: 20, color: context.palette.ink),
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
