import 'package:docxan/app/flavor.dart';
import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/app_router.dart';
import 'package:docxan/app/theme/app_theme.dart';
import 'package:docxan/features/auth/presentation/controllers/auth_session_binder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocxanApp extends ConsumerWidget {
  const DocxanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final flavor = ref.watch(flavorConfigProvider);

    return AuthSessionBinder(
      child: MaterialApp.router(
        title: flavor.displayName,
        debugShowCheckedModeBanner: flavor.isDev,
        theme: DocxanTheme.light(),
        routerConfig: router,
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
