import 'dart:async';

import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/features/auth/domain/entities/auth_user.dart';
import 'package:docxan/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthSessionBinder extends ConsumerStatefulWidget {
  const AuthSessionBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthSessionBinder> createState() => _AuthSessionBinderState();
}

class _AuthSessionBinderState extends ConsumerState<AuthSessionBinder> {
  StreamSubscription<AuthUser?>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = ref.read(authRepositoryProvider);
      final current = repo.currentUser;
      if (current != null) {
        ref.read(sessionProvider.notifier).signIn(
          email: current.email ?? '',
          userId: current.id,
        );
      }
      _subscription = repo.authChanges().listen((user) {
        if (!mounted) return;
        final session = ref.read(sessionProvider);
        if (user == null) {
          if (session.isAuthenticated) {
            ref.read(sessionProvider.notifier).signOut();
          }
          return;
        }
        ref.read(sessionProvider.notifier).signIn(
          email: user.email ?? '',
          userId: user.id,
        );
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
