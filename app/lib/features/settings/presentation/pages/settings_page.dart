import 'package:doxan/app/flavor.dart';
import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/library/local_library_catalog.dart';
import 'package:doxan/core/security/biometric_service.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/core/storage/storage_stats.dart';
import 'package:doxan/core/sync/sync_manager.dart';
import 'package:doxan/core/utils/formatters.dart';
import 'package:doxan/core/widgets/doxan_app_header.dart';
import 'package:doxan/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  StorageStats? _stats;

  @override
  void initState() {
    super.initState();
    _reloadStats();
  }

  Future<void> _reloadStats() async {
    final stats = await ref.read(storageStatsServiceProvider).load();
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final flavor = ref.watch(flavorConfigProvider);
    final used = formatBytes(_stats?.usedBytes ?? 0);
    final total = _stats?.totalBytes == null
        ? l10n.unknownStorage
        : formatBytes(_stats!.totalBytes!);

    return Scaffold(
      backgroundColor: DoxanColors.paper,
      body: SafeArea(
        child: ListView(
          children: [
            DoxanAppHeader(onProfile: () {}),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                l10n.settings,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ListTile(
              title: Text(l10n.profile),
              subtitle: Text(
                session.isGuest
                    ? l10n.continueAsGuest
                    : (session.email ?? session.userId ?? l10n.account),
              ),
            ),
            if (flavor.isDev)
              const ListTile(title: Text('Flavor'), subtitle: Text('dev')),
            const Divider(),
            ListTile(
              title: Text(l10n.security),
              subtitle: Text(l10n.pin),
            ),
            ListTile(
              title: Text(l10n.changePin),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('${AppRoutes.pinSetup}?change=1'),
            ),
            SwitchListTile(
              title: Text(l10n.biometrics),
              value: session.biometricsEnabled,
              onChanged: (value) => _toggleBiometrics(value),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.language),
              subtitle: Text(l10n.spanish),
            ),
            ListTile(
              title: Text(l10n.theme),
              subtitle: Text(l10n.lightTheme),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.storageStatus),
              subtitle: Text(l10n.storageUsedOf(used, total)),
            ),
            ListTile(
              title: Text(l10n.cleanCache),
              subtitle: Text(
                formatBytes(_stats?.cacheBytes ?? 0),
              ),
              onTap: () async {
                await ref.read(storageStatsServiceProvider).cleanCache();
                await _reloadStats();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.cacheCleaned)));
              },
            ),
            ListTile(
              title: Text(l10n.deleteLocalDocuments),
              onTap: () => _deleteAll(l10n),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.backup),
              subtitle: Text(l10n.backupSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.backup),
            ),
            ListTile(
              title: Text(l10n.syncAction),
              subtitle: Text(l10n.backupSubtitle),
              onTap: () => _syncNow(l10n),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.privacyPolicy),
              onTap: () => context.push(AppRoutes.legalPath('privacy')),
            ),
            ListTile(
              title: Text(l10n.termsOfUse),
              onTap: () => context.push(AppRoutes.legalPath('terms')),
            ),
            const Divider(),
            ListTile(
              title: Text(
                l10n.signOut,
                style: const TextStyle(color: DoxanColors.danger),
              ),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                ref.read(sessionProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.onboarding);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _syncNow(AppLocalizations l10n) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.syncInProgress)));
    final report = await ref.read(syncManagerProvider).synchronize();
    if (!mounted) return;
    final message = switch (report.status) {
      SyncRunStatus.skipped => report.message ?? l10n.syncNeedAccount,
      SyncRunStatus.failed => report.message ?? l10n.syncFailedMessage,
      _ => report.message ?? l10n.syncComplete,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleBiometrics(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    if (enabled) {
      final available = await ref.read(biometricServiceProvider).isAvailable();
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.biometricsUnavailable)));
        return;
      }
      final ok = await ref
          .read(biometricServiceProvider)
          .authenticate(l10n.unlockWithBiometrics);
      if (!ok) return;
    }
    ref.read(sessionProvider.notifier).setBiometricsEnabled(enabled: enabled);
  }

  Future<void> _deleteAll(AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteAll),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(libraryCatalogProvider.notifier).deleteAllDocuments();
    await _reloadStats();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.documentsDeleted)));
  }
}
