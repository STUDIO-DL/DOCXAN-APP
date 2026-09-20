import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/shell/main_shell.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/features/auth/auth.dart';
import 'package:docxan/features/backup/backup.dart';
import 'package:docxan/features/document/document.dart';
import 'package:docxan/features/folders/folders.dart';
import 'package:docxan/features/home/home.dart';
import 'package:docxan/features/lock/lock.dart';
import 'package:docxan/features/onboarding/onboarding.dart';
import 'package:docxan/features/scan/scan.dart';
import 'package:docxan/features/search/search.dart';
import 'package:docxan/features/settings/settings.dart';
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
      final onPinSetup = loc == AppRoutes.pinSetup;
      final onLegal = loc.startsWith('/settings/legal');

      if (!session.splashDone) {
        return onSplash ? null : AppRoutes.splash;
      }
      if (onSplash) {
        return session.onboardingComplete
            ? (session.pinSet ? AppRoutes.home : AppRoutes.pinSetup)
            : AppRoutes.onboarding;
      }
      if (!session.onboardingComplete &&
          !onOnboarding &&
          !onAuth &&
          !onLegal) {
        return AppRoutes.onboarding;
      }
      if (session.onboardingComplete &&
          !session.pinSet &&
          !onPinSetup &&
          !onAuth &&
          !onOnboarding) {
        return AppRoutes.pinSetup;
      }
      if (session.pinSet && !session.unlocked && !onLock && !onPinSetup) {
        return AppRoutes.lock;
      }
      if (onLock && (!session.pinSet || session.unlocked)) {
        return AppRoutes.home;
      }
      if (onPinSetup && session.pinSet && session.unlocked) {
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
        path: AppRoutes.pinSetup,
        builder: (context, state) => PinSetupPage(
          changing: state.uri.queryParameters['change'] == '1',
        ),
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
      GoRoute(
        path: AppRoutes.legal,
        builder: (context, state) => LegalPage(
          kind: state.pathParameters['kind'] ?? 'privacy',
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
                routes: [
                  GoRoute(
                    path: ':folderId',
                    builder: (context, state) => FolderDetailPage(
                      folderId: state.pathParameters['folderId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scan,
                builder: (context, state) => const CapturePage(),
                routes: [
                  GoRoute(
                    path: 'capture',
                    builder: (context, state) => const CapturePage(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchPage(),
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
