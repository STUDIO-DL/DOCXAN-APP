import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/demo/demo_catalog.dart';
import 'package:doxan/core/models/library_models.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/core/utils/formatters.dart';
import 'package:doxan/core/widgets/doxan_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final greetingKey = greetingFor(DateTime.now());
    final greeting = switch (greetingKey) {
      'morning' => l10n.goodMorning,
      'afternoon' => l10n.goodAfternoon,
      _ => l10n.goodEvening,
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            DoxanSearchBar(
              hint: l10n.searchDocuments,
              onTap: () => context.push(AppRoutes.search),
            ),
            const SizedBox(height: 24),
            Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
            if (session.isGuest) ...[
              const SizedBox(height: 12),
              _GuestBanner(
                message: l10n.guestBanner,
                action: l10n.createAccount,
                onTap: () => context.push(AppRoutes.register),
              ),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  icon: Icons.cloud_off_outlined,
                  label: session.backupEnabled ? l10n.syncOk : l10n.syncOffline,
                ),
                _StatusChip(
                  icon: Icons.sd_storage_outlined,
                  label: '${l10n.storageStatus} · 1.1 MB',
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(l10n.recents, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final doc in DemoCatalog.documents)
              _DocumentTile(
                document: doc,
                onTap: () => context.push(AppRoutes.documentPath(doc.id)),
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
        color: DoxanColors.chip,
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
        color: DoxanColors.paper,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DoxanColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DoxanColors.inkMuted),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document, required this.onTap});

  final DocumentSummary document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DoxanColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DoxanColors.hairline),
        ),
        child: const Icon(Icons.description_outlined, color: DoxanColors.ink),
      ),
      title: Text(document.name),
      subtitle: Text(
        '${document.format} · ${formatBytes(document.sizeBytes)}',
      ),
      trailing: document.isDemo
          ? const Text('Demo', style: TextStyle(color: DoxanColors.inkMuted))
          : null,
    );
  }
}
