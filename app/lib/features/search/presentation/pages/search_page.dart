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

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  String? _format;
  String? _tag;
  String? _date;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final documents = ref.watch(libraryProvider).documents;
    final results = documents.where((doc) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          doc.name.toLowerCase().contains(q) ||
          doc.folderName.toLowerCase().contains(q) ||
          doc.ocrText.toLowerCase().contains(q);
      final matchesFormat =
          _format == null || doc.format.toUpperCase() == _format;
      return matchesQuery && matchesFormat;
    }).toList();

    return Scaffold(
      backgroundColor: DocxanColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            DocxanAppHeader(title: l10n.searchTitle),
            const SizedBox(height: 20),
            DocxanSearchBar(
              hint: l10n.searchDocuments,
              controller: _controller,
              autofocus: false,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 24),
            Text(l10n.searchFilters, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _FilterGroup(
              label: l10n.fileType,
              options: const ['PDF', 'DOCX', 'JPG'],
              value: _format,
              onSelected: (value) => setState(() {
                _format = _format == value ? null : value;
              }),
            ),
            const SizedBox(height: 14),
            _FilterGroup(
              label: l10n.tags,
              options: [l10n.urgent, l10n.pending],
              value: _tag,
              onSelected: (value) => setState(() {
                _tag = _tag == value ? null : value;
              }),
            ),
            const SizedBox(height: 14),
            _FilterGroup(
              label: l10n.date,
              options: [l10n.today, l10n.thisWeek, l10n.lastMonth],
              value: _date,
              onSelected: (value) => setState(() {
                _date = _date == value ? null : value;
              }),
            ),
            const SizedBox(height: 20),
            if (results.isEmpty)
              DocxanEmptyState(
                icon: Icons.search_off,
                title: l10n.emptySearch,
                body: l10n.emptySearchBody,
              )
            else
              for (final doc in results)
                DocxanDocumentTile(
                  document: doc,
                  onTap: () => context.push(AppRoutes.documentPath(doc.id)),
                ),
          ],
        ),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.label,
    required this.options,
    required this.value,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: value == option,
                onSelected: (_) => onSelected(option),
                selectedColor: DocxanColors.chip,
                backgroundColor: DocxanColors.canvas,
                side: const BorderSide(color: DocxanColors.hairline),
                labelStyle: TextStyle(
                  color: DocxanColors.ink,
                  fontWeight: value == option ? FontWeight.w600 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
