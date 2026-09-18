import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/app/theme/spacing.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/core/widgets/doxan_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DoxanColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const DoxanLogo(size: 120),
            const SizedBox(height: DoxanSpacing.md),
            Text(
              l10n.onboardingTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.onboardingBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.onboardingPrivacy,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: DoxanColors.ink,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.privacyPolicy),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.termsOfUse),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                ref.read(sessionProvider.notifier).enterAsGuest();
                context.go(AppRoutes.home);
              },
              child: Text(l10n.getStarted),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: Text(l10n.signIn),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.push(AppRoutes.register),
              child: Text(l10n.createAccount),
            ),
          ],
        ),
      ),
    );
  }
}
