import 'dart:io';

import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/library/local_library_catalog.dart';
import 'package:doxan/core/models/saved_document.dart';
import 'package:doxan/core/utils/formatters.dart';
import 'package:doxan/core/widgets/doxan_app_header.dart';
import 'package:doxan/core/widgets/doxan_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _SearchFilter { all, recents, ocr, pdf }

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  _SearchFilter _filter = _SearchFilter.all;
  List<SavedDocument> _results = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final q = _query.trim();
    if (q.isEmpty && _filter == _SearchFilter.all) {
      setState(() => _results = const []);
      return;
    }
    final results = await ref.read(libraryCatalogProvider.notifier).search(
      q,
      recentsOnly: _filter == _SearchFilter.recents,
      ocrOnly: _filter == _SearchFilter.ocr,
      pdfOnly: _filter == _SearchFilter.pdf,
    );
    if (!mounted) return;
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen(libraryCatalogProvider, (_, next) {
      _runSearch();
    });

    return Scaffold(
      backgroundColor: DoxanColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            DoxanAppHeader(onProfile: () => context.go(AppRoutes.settings)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l10n.searchTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  _query = value;
                  _runSearch();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: Text(l10n.allFolders),
                    selected: _filter == _SearchFilter.all,
                    onSelected: (_) {
                      setState(() => _filter = _SearchFilter.all);
                      _runSearch();
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.recents),
                    selected: _filter == _SearchFilter.recents,
                    onSelected: (_) {
                      setState(() => _filter = _SearchFilter.recents);
                      _runSearch();
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.filterOcr),
                    selected: _filter == _SearchFilter.ocr,
                    onSelected: (_) {
                      setState(() => _filter = _SearchFilter.ocr);
                      _runSearch();
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.exportPdf),
                    selected: _filter == _SearchFilter.pdf,
                    onSelected: (_) {
                      setState(() => _filter = _SearchFilter.pdf);
                      _runSearch();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _query.isEmpty && _filter == _SearchFilter.all
                  ? const SizedBox.shrink()
                  : _results.isEmpty
                  ? DoxanEmptyState(
                      icon: Icons.search_off,
                      title: l10n.emptySearch,
                      body: l10n.searchHint,
                    )
                  : ListView(
                      children: [
                        for (final doc in _results)
                          ListTile(
                            leading: _Thumb(path: doc.previewPath),
                            title: Text(doc.summary.name),
                            subtitle: Text(
                              '${doc.summary.folderName} · ${formatBytes(doc.summary.sizeBytes)}',
                            ),
                            onTap: () =>
                                context.push(AppRoutes.documentPath(doc.id)),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DoxanColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: has
          ? Image.file(File(path), fit: BoxFit.cover)
          : const Icon(Icons.description_outlined),
    );
  }
}
