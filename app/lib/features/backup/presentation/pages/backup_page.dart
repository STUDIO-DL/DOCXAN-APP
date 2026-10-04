import 'dart:async';

import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/data/user_settings_repository.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/security/pin_service.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/sync/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool _busy = false;

  Future<void> _toggleBackup(bool enabled) async {
    ref.read(sessionProvider.notifier).setBackupEnabled(enabled: enabled);
    final settings = await ref.read(userSettingsRepositoryProvider).load();
    await ref.read(userSettingsRepositoryProvider).save(
      settings.copyWith(backupEnabled: enabled),
    );
    if (enabled) {
      await ref.read(libraryCatalogProvider.notifier).enqueueBackupsForAll();
    }
  }

  Future<void> _sync() async {
    final l10n = AppLocalizations.of(context);
    if (!await _ensurePin(l10n)) return;
    setState(() => _busy = true);
    final report = await ref.read(syncManagerProvider).synchronize();
    unawaited(notifySyncResult(l10n, report));
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizedSyncReport(l10n, report))),
    );
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final pin = await _askPin(l10n);
    if (pin == null) return;
    final ok = await ref.read(pinServiceProvider).verify(pin);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pinWrong)),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final report = await ref.read(syncManagerProvider).restoreFromCloud(pin: pin);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedSyncReport(l10n, report))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restoreFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _ensurePin(AppLocalizations l10n) async {
    if (ref.read(pinServiceProvider).verifiedPin != null) return true;
    final pin = await _askPin(l10n);
    if (pin == null) return false;
    final ok = await ref.read(pinServiceProvider).verify(pin);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pinWrong)),
      );
    }
    return ok;
  }

  Future<String?> _askPin(AppLocalizations l10n) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lockTitle),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(hintText: l10n.lockSubtitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              l10n.onboardingPrivacy,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.backup),
              subtitle: Text(
                session.isAuthenticated
                    ? l10n.backupSubtitle
                    : l10n.syncNeedAccount,
              ),
              value: session.backupEnabled,
              onChanged: !session.isAuthenticated || _busy
                  ? null
                  : _toggleBackup,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _sync,
              child: Text(_busy ? l10n.syncInProgress : l10n.syncAction),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _restore,
              child: Text(l10n.restoreBackup),
            ),
            const Spacer(),
            Text(l10n.trash, style: Theme.of(context).textTheme.titleMedium),
            Text(
              l10n.confirmDeleteDocument,
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
