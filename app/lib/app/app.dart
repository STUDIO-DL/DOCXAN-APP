import 'package:docxan/app/flavor.dart';
import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/app_router.dart';
import 'package:docxan/app/theme/app_theme.dart';
import 'package:docxan/core/session/session_controller.dart';
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
      child: _LockOnBackground(
        child: MaterialApp.router(
          title: flavor.displayName,
          debugShowCheckedModeBanner: flavor.isDev,
          theme: DocxanTheme.light(),
          routerConfig: router,
          locale: const Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
    } else if (state == AppLifecycleState.resumed) {
      session.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
