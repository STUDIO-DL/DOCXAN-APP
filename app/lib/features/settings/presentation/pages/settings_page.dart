import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/widgets/docxan_library_tiles.dart';
import 'package:docxan/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DocxanColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            DocxanAppHeader(title: l10n.settings),
            const SizedBox(height: 24),
            _GroupTitle(l10n.accountAndProfile),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.sd_storage_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: l10n.storagePlan,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF7C3AED),
                  title: l10n.personalData,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 22),
            _GroupTitle(l10n.documentsSection),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.translate,
                  iconColor: DocxanColors.accent,
                  title: l10n.ocrLanguage,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF0D9488),
                  title: l10n.defaultFormat,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 22),
            _GroupTitle(l10n.application),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: l10n.securityAndPrivacy,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  iconColor: const Color(0xFFE11D48),
                  title: l10n.notifications,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: DocxanColors.accent,
                  title: l10n.themeAndAppearance,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 18),
            _EmptyStorageCard(title: l10n.totalStorage),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                ref.read(sessionProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.onboarding);
              },
              child: Text(
                l10n.signOut,
                style: const TextStyle(color: DocxanColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DocxanColors.canvas,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right, color: DocxanColors.inkMuted),
      onTap: onTap,
    );
  }
}

class _EmptyStorageCard extends StatelessWidget {
  const _EmptyStorageCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: DocxanColors.canvas,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: DocxanColors.ink.withValues(alpha: 0.08),
            child: const Icon(
              Icons.sd_storage_outlined,
              color: DocxanColors.ink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
