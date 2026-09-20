import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/library/library_controller.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/utils/formatters.dart';
import 'package:docxan/core/widgets/docxan_empty_state.dart';
import 'package:docxan/core/widgets/docxan_library_tiles.dart';
import 'package:docxan/core/widgets/docxan_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final library = ref.watch(libraryProvider);
    final recents = library.documents;
    final recentFolders = library.folders;
    final greeting = switch (greetingFor(DateTime.now())) {
      'morning' => l10n.goodMorning,
      'afternoon' => l10n.goodAfternoon,
      _ => l10n.goodEvening,
    };

    return Scaffold(
      backgroundColor: DocxanColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            DocxanAppHeader(title: l10n.appName, showBrand: true),
            const SizedBox(height: 24),
            Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              l10n.homeSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            DocxanSearchBar(
              hint: l10n.searchDocuments,
              onTap: () => context.go(AppRoutes.search),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    icon: Icons.cloud_upload_outlined,
                    title: l10n.syncStatus,
                    subtitle: session.backupEnabled ? l10n.syncOk : l10n.syncOffline,
                    showDot: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    icon: Icons.sd_storage_outlined,
                    title: l10n.storageStatus,
                    subtitle: formatBytes(library.usedBytes),
                  ),
                ),
              ],
            ),
            if (session.isGuest) ...[
              const SizedBox(height: 16),
              _GuestBanner(
                message: l10n.guestBanner,
                action: l10n.createAccount,
                onTap: () => context.push(AppRoutes.register),
              ),
            ],
            const SizedBox(height: 28),
            DocxanSectionHeader(
              title: l10n.recentDocuments,
              action: l10n.viewAll,
              onAction: () => context.go(AppRoutes.search),
            ),
            if (recents.isEmpty)
              DocxanEmptyState(
                icon: Icons.description_outlined,
                title: l10n.emptyDocuments,
                body: l10n.emptyDocumentsBody,
              )
            else
              for (final doc in recents)
                DocxanDocumentTile(
                  document: doc,
                  onTap: () => context.push(AppRoutes.documentPath(doc.id)),
                ),
            const SizedBox(height: 16),
            DocxanSectionHeader(
              title: l10n.recentFolders,
              action: l10n.viewAll,
              onAction: () => context.go(AppRoutes.folders),
            ),
            if (recentFolders.isEmpty)
              DocxanEmptyState(
                icon: Icons.folder_outlined,
                title: l10n.emptyFolders,
                body: l10n.emptyFoldersBody,
              )
            else
              SizedBox(
                height: 92,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final folder in recentFolders.take(4))
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: DocxanFolderCard(
                          folder: folder,
                          compact: true,
                          onTap: () => context.go(AppRoutes.folders),
                        ),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showDot = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DocxanColors.canvas,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: DocxanColors.inkMuted),
              const Spacer(),
              if (showDot)
                const CircleAvatar(radius: 4, backgroundColor: DocxanColors.accent),
              const Icon(Icons.chevron_right, size: 18, color: DocxanColors.inkMuted),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  const _GuestBanner({
    required this.message,
    required this.action,
    required this.onTap,
  });

  final String message;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DocxanColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}
