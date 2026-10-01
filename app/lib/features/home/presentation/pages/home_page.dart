import 'dart:io';

import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/library/folder_labels.dart';
import 'package:docxan/core/library/library_collections.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/models/library_models.dart';
import 'package:docxan/core/models/sync_status.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/utils/formatters.dart';
import 'package:docxan/core/widgets/doxan_app_header.dart';
import 'package:docxan/core/widgets/doxan_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final library = ref.watch(libraryCatalogProvider);
    final recents = library.inCollection(LibraryCollections.recent);
    final greetingKey = greetingFor(DateTime.now());
    final greeting = switch (greetingKey) {
      'morning' => l10n.goodMorning,
      'afternoon' => l10n.goodAfternoon,
      _ => l10n.goodEvening,
    };
    final used = library.activeDocuments.fold<int>(
      0,
      (sum, doc) => sum + doc.summary.sizeBytes,
    );

    return Scaffold(
      backgroundColor: DocxanColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            DoxanAppHeader(onProfile: () => context.go(AppRoutes.settings)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: DoxanSearchBar(
                hint: l10n.searchDocuments,
                onTap: () => context.go(AppRoutes.search),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                greeting,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            if (session.isGuest)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _GuestBanner(
                  message: l10n.guestBanner,
                  action: l10n.createAccount,
                  onTap: () => context.push(AppRoutes.register),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    icon: switch (library.aggregateSyncStatus) {
                      SyncStatus.synced => Icons.cloud_done_outlined,
                      SyncStatus.uploading => Icons.cloud_sync_outlined,
                      SyncStatus.pendingUpload => Icons.cloud_upload_outlined,
                      SyncStatus.failed => Icons.cloud_off_outlined,
                      SyncStatus.localOnly => Icons.cloud_off_outlined,
                    },
                    label: switch (library.aggregateSyncStatus) {
                      SyncStatus.synced => l10n.syncOk,
                      SyncStatus.uploading => l10n.syncUploading,
                      SyncStatus.pendingUpload => l10n.syncPending,
                      SyncStatus.failed => l10n.syncFailed,
                      SyncStatus.localOnly => l10n.syncOffline,
                    },
                  ),
                  _StatusChip(
                    icon: Icons.sd_storage_outlined,
                    label: '${l10n.storageStatus} · ${formatBytes(used)}',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recentDocuments,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(
                      AppRoutes.folderPath(LibraryCollections.recent),
                    ),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
            ),
            if (recents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.emptyCollection,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final doc in recents.take(8))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _DocumentTile(
                    document: doc.summary,
                    previewPath: doc.previewPath,
                    onTap: () => context.push(AppRoutes.documentPath(doc.id)),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recentFolders,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.folders),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final folder in library.folders.take(8))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(localizedSavedFolderName(l10n, folder)),
                        onPressed: () =>
                            context.push(AppRoutes.folderPath(folder.id)),
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
        color: DocxanColors.chip,
        borderRadius: BorderRadius.circular(14),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DocxanColors.paper,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DocxanColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DocxanColors.inkMuted),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.onTap,
    this.previewPath,
  });

  final DocumentSummary document;
  final VoidCallback onTap;
  final String? previewPath;

  @override
  Widget build(BuildContext context) {
    final preview = previewPath;
    final hasPreview = preview != null && File(preview).existsSync();
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DocxanColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DocxanColors.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasPreview
            ? Image.file(File(preview), fit: BoxFit.cover)
            : const Icon(Icons.description_outlined, color: DocxanColors.ink),
      ),
      title: Text(document.name),
      subtitle: Text(
        '${document.format} · ${formatBytes(document.sizeBytes)}',
      ),
    );
  }
}
