import 'dart:async';

import 'package:docxan/app/l10n/app_localizations.dart';
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
    try {
      final report = await ref.read(syncManagerProvider).synchronize();
      unawaited(notifySyncResult(l10n, report));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedSyncReport(l10n, report))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.syncFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    if (await _showLockoutIfAny(l10n)) return;
    if (!mounted) return;
    final pin = await _askPin(l10n);
    if (pin == null) return;
    if (!await _checkPin(l10n, pin)) return;
    if (!mounted) return;
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
    if (await _showLockoutIfAny(l10n)) return false;
    if (!mounted) return false;
    final pin = await _askPin(l10n);
    if (pin == null) return false;
    return _checkPin(l10n, pin);
  }

  /// Shows the lockout message and returns true when PIN entry is blocked.
  Future<bool> _showLockoutIfAny(AppLocalizations l10n) async {
    final remaining = await ref.read(pinServiceProvider).remainingLockout();
    if (remaining <= Duration.zero) return false;
    if (mounted) _showPinMessage(l10n.pinTooManyAttempts(_ceilSeconds(remaining)));
    return true;
  }

  Future<bool> _checkPin(AppLocalizations l10n, String pin) async {
    final result = await ref.read(pinServiceProvider).check(pin);
    if (!result.ok && mounted) {
      _showPinMessage(
        result.lockedOut
            ? l10n.pinTooManyAttempts(_ceilSeconds(result.lockout))
            : l10n.pinWrong,
      );
    }
    return result.ok;
  }

  void _showPinMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static int _ceilSeconds(Duration duration) {
    return (duration.inMilliseconds / 1000).ceil();
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
              ).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
