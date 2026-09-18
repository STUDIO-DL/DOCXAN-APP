import 'package:doxan/app/flavor.dart';
import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/router/app_router.dart';
import 'package:doxan/app/theme/app_theme.dart';
import 'package:doxan/features/auth/presentation/controllers/auth_session_binder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoxanApp extends ConsumerWidget {
  const DoxanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final flavor = ref.watch(flavorConfigProvider);

    return AuthSessionBinder(
      child: MaterialApp.router(
        title: flavor.displayName,
        debugShowCheckedModeBanner: flavor.isDev,
        theme: DoxanTheme.light(),
        routerConfig: router,
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
