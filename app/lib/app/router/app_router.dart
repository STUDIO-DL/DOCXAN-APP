import 'package:doxan/app/router/routes.dart';
import 'package:doxan/app/shell/main_shell.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/features/auth/auth.dart';
import 'package:doxan/features/backup/backup.dart';
import 'package:doxan/features/document/document.dart';
import 'package:doxan/features/folders/folders.dart';
import 'package:doxan/features/home/home.dart';
import 'package:doxan/features/lock/lock.dart';
import 'package:doxan/features/onboarding/onboarding.dart';
import 'package:doxan/features/scan/scan.dart';
import 'package:doxan/features/search/search.dart';
import 'package:doxan/features/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;
      final onSplash = loc == AppRoutes.splash;
      final onOnboarding = loc == AppRoutes.onboarding;
      final onAuth = loc.startsWith('/auth');
      final onLock = loc == AppRoutes.lock;

      if (!session.splashDone) {
        return onSplash ? null : AppRoutes.splash;
      }
      if (onSplash) {
        return session.onboardingComplete
            ? AppRoutes.home
            : AppRoutes.onboarding;
      }
      if (!session.onboardingComplete && !onOnboarding && !onAuth) {
        return AppRoutes.onboarding;
      }
      if (session.pinSet && !session.unlocked && !onLock) {
        return AppRoutes.lock;
      }
      if (onLock && (!session.pinSet || session.unlocked)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.lock,
        builder: (context, state) => const LockPage(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.backup,
        builder: (context, state) => const BackupPage(),
      ),
      GoRoute(
        path: AppRoutes.document,
        builder: (context, state) => DocumentPage(
          documentId: state.pathParameters['id'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.folders,
                builder: (context, state) => const FoldersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scan,
                builder: (context, state) => const ScanPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
