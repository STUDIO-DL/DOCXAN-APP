import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/demo/demo_catalog.dart';
import 'package:doxan/core/extensions/date_time_x.dart';
import 'package:doxan/core/widgets/doxan_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FoldersPage extends StatelessWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: DoxanSearchBar(
                hint: l10n.searchDocuments,
                onTap: () => context.push(AppRoutes.search),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
                children: [
                  for (final folder in DemoCatalog.folders)
                    ListTile(
                      leading: const Icon(
                        Icons.folder_outlined,
                        color: DoxanColors.ink,
                      ),
                      title: Text(folder.name),
                      subtitle: Text(
                        '${l10n.documentsCount(folder.documentCount)} · ${folder.updatedAt.toShortDate()}',
                      ),
                      onTap: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: DoxanColors.ink,
        foregroundColor: DoxanColors.paper,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.newFolder),
      ),
    );
  }
}
