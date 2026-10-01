import 'package:docxan/app/flavor.dart';
import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/data/user_settings_repository.dart';
import 'package:docxan/core/imaging/compression_profile.dart';
import 'package:docxan/core/library/local_library_catalog.dart';
import 'package:docxan/core/locale/app_locales.dart';
import 'package:docxan/core/security/biometric_service.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/storage/storage_stats.dart';
import 'package:docxan/core/sync/sync_manager.dart';
import 'package:docxan/core/theme/app_theme_controller.dart';
import 'package:docxan/core/utils/formatters.dart';
import 'package:docxan/core/widgets/doxan_app_header.dart';
import 'package:docxan/core/widgets/language_picker.dart';
import 'package:docxan/features/auth/presentation/controllers/auth_providers.dart';
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
  String _compression = CompressionProfile.balanced.id;

  @override
  void initState() {
    super.initState();
    _reloadStats();
    _loadCompression();
  }

  Future<void> _loadCompression() async {
    final settings = await ref.read(userSettingsRepositoryProvider).load();
    if (mounted) {
      setState(() => _compression = settings.compressionProfile);
    }
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
      backgroundColor: DocxanColors.paper,
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
              subtitle: Text(
                AppLocales.displayName(
                  l10n,
                  Localizations.localeOf(context).languageCode,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLanguagePickerSheet(context),
            ),
            ListTile(
              title: Text(l10n.theme),
              subtitle: Text(
                ref.watch(appThemeModeProvider) == ThemeMode.dark
                    ? l10n.darkTheme
                    : l10n.lightTheme,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTheme(l10n),
            ),
            ListTile(
              title: Text(l10n.compression),
              subtitle: Text(_compressionLabel(l10n, _compression)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickCompression(l10n),
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
                style: const TextStyle(color: DocxanColors.danger),
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
    final message = localizedSyncReport(l10n, report);
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

  String _compressionLabel(AppLocalizations l10n, String id) {
    return switch (id) {
      'small' => l10n.compressionSmall,
      'high' => l10n.compressionHigh,
      _ => l10n.compressionBalanced,
    };
  }

  Future<void> _pickTheme(AppLocalizations l10n) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.lightTheme),
              onTap: () => Navigator.pop(context, ThemeMode.light),
            ),
            ListTile(
              title: Text(l10n.darkTheme),
              onTap: () => Navigator.pop(context, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await ref.read(appThemeModeProvider.notifier).setMode(selected);
  }

  Future<void> _pickCompression(AppLocalizations l10n) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final profile in CompressionProfile.values)
              ListTile(
                title: Text(_compressionLabel(l10n, profile.id)),
                onTap: () => Navigator.pop(context, profile.id),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    final settings = await ref.read(userSettingsRepositoryProvider).load();
    await ref.read(userSettingsRepositoryProvider).save(
      settings.copyWith(compressionProfile: selected),
    );
    if (mounted) setState(() => _compression = selected);
  }
}
