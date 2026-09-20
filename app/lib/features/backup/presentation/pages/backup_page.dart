import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backup)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.backupSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Los blobs se cifran en el dispositivo y se suben a Cloudflare R2 con URLs prefirmadas. El token S3 nunca viaja en la app.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: session.isAuthenticated
                  ? () {
                      ref
                          .read(sessionProvider.notifier)
                          .setBackupEnabled(enabled: true);
                    }
                  : null,
              child: Text(l10n.backup),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: session.isAuthenticated ? () {} : null,
              child: Text(l10n.restoreBackup),
            ),
            const Spacer(),
            Text(
              l10n.trash,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Hard delete a los 30 días. Pendiente de Drift + R2.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: DocxanColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
