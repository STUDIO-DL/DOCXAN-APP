import 'dart:async';

import 'package:doxan/core/data/profile_repository.dart';
import 'package:doxan/core/models/profile.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/features/auth/domain/entities/auth_user.dart';
import 'package:doxan/features/auth/presentation/controllers/auth_providers.dart';
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
        _bindUser(current);
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
        _bindUser(user);
      });
    });
  }

  void _bindUser(AuthUser user) {
    ref.read(sessionProvider.notifier).signIn(
      email: user.email ?? '',
      userId: user.id,
    );
    ref.read(profileRepositoryProvider).upsert(
      Profile(
        id: user.id,
        email: user.email,
        displayName: user.email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
