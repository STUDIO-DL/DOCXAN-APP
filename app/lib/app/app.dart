import 'dart:async';

import 'package:docxan/app/flavor.dart';
import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/app_router.dart';
import 'package:docxan/app/theme/app_theme.dart';
import 'package:docxan/core/locale/app_locale_controller.dart';
import 'package:docxan/core/locale/app_locales.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:docxan/core/theme/app_theme_controller.dart';
import 'package:docxan/features/auth/presentation/controllers/auth_session_binder.dart';
import 'package:docxan/features/scan/presentation/controllers/scan_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocxanApp extends ConsumerWidget {
  const DocxanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final flavor = ref.watch(flavorConfigProvider);
    final overrideCode = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return AuthSessionBinder(
      child: _LockOnBackground(
        child: MaterialApp.router(
          title: flavor.displayName,
          debugShowCheckedModeBanner: flavor.isDev,
          theme: DocxanTheme.light(),
          darkTheme: DocxanTheme.dark(),
          themeMode: themeMode,
          routerConfig: router,
          locale: overrideCode == null ? null : Locale(overrideCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeListResolutionCallback: (deviceLocales, _) {
            return AppLocales.resolve(
              overrideCode: overrideCode,
              deviceLocales: deviceLocales ?? const <Locale>[],
            );
          },
        ),
      ),
    );
  }
}

class _LockOnBackground extends ConsumerStatefulWidget {
  const _LockOnBackground({required this.child});

  final Widget child;

  @override
  ConsumerState<_LockOnBackground> createState() => _LockOnBackgroundState();
}

class _LockOnBackgroundState extends ConsumerState<_LockOnBackground>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = ref.read(sessionProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      session.onAppPaused();
      if (state == AppLifecycleState.paused) _sweepTemps();
    } else if (state == AppLifecycleState.resumed) {
      session.onAppResumed();
    }
  }

  /// Drops stale plaintext temps; pages of the open scan session are kept.
  void _sweepTemps() {
    final keep = ref
        .read(scanSessionProvider)
        .pages
        .map((page) => page.path)
        .toSet();
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    unawaited(
      ref.read(localFileStoreProvider).sweepTemps(
        scanCutoff: cutoff,
        pluginCutoff: cutoff,
        keep: keep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
