import 'package:doxan/app/flavor.dart';
import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/session/session.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final flavor = ref.watch(flavorConfigProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.account),
            subtitle: Text(
              session.isGuest
                  ? l10n.continueAsGuest
                  : (session.email ?? session.userId ?? l10n.account),
            ),
          ),
          if (flavor.isDev)
            const ListTile(
              title: Text('Flavor'),
              subtitle: Text('dev'),
            ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.pin),
            value: session.pinSet,
            onChanged: (value) {
              ref.read(sessionProvider.notifier).setPinConfigured(enabled: value);
            },
          ),
          SwitchListTile(
            title: Text(l10n.biometrics),
            subtitle: Text(l10n.comingSoon),
            value: false,
            onChanged: null,
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.backup),
            subtitle: Text(l10n.backupSubtitle),
            value: session.backupEnabled,
            onChanged: session.status == AuthStatus.authenticated
                ? (value) {
                    ref
                        .read(sessionProvider.notifier)
                        .setBackupEnabled(enabled: value);
                  }
                : null,
          ),
          ListTile(
            title: Text(l10n.restoreBackup),
            onTap: () => context.push(AppRoutes.backup),
          ),
          ListTile(
            title: Text(l10n.compression),
            subtitle: Text(l10n.compressionBalanced),
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
        ],
      ),
    );
  }
}
