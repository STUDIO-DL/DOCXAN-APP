import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/core/demo/demo_catalog.dart';
import 'package:doxan/core/utils/formatters.dart';
import 'package:doxan/core/widgets/doxan_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = DemoCatalog.documents.where((doc) {
      if (_query.trim().isEmpty) return false;
      final q = _query.toLowerCase();
      return doc.name.toLowerCase().contains(q) ||
          doc.folderName.toLowerCase().contains(q) ||
          doc.ocrText.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: _query.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l10n.searchFilters,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(label: Text(l10n.folders), onSelected: (_) {}),
                    const FilterChip(label: Text('PDF'), onSelected: null),
                    FilterChip(label: Text(l10n.recents), onSelected: (_) {}),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.recentSearches,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Universidad'),
                  onTap: () {
                    _controller.text = 'Universidad';
                    setState(() => _query = 'Universidad');
                  },
                ),
              ],
            )
          : results.isEmpty
          ? DoxanEmptyState(
              icon: Icons.search_off,
              title: l10n.emptySearch,
              body: l10n.searchHint,
            )
          : ListView(
              children: [
                for (final doc in results)
                  ListTile(
                    title: Text(doc.name),
                    subtitle: Text(
                      '${doc.folderName} · ${formatBytes(doc.sizeBytes)}',
                    ),
                    onTap: () => context.push(AppRoutes.documentPath(doc.id)),
                  ),
              ],
            ),
    );
  }
}

