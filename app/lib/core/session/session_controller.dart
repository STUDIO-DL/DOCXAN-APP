import 'package:docxan/core/session/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionController extends Notifier<Session> {
  @override
  Session build() => const Session(status: AuthStatus.unknown);

  void finishSplash() {
    state = state.copyWith(splashDone: true);
  }

  void enterAsGuest() {
    state = state.copyWith(
      status: AuthStatus.guest,
      onboardingComplete: true,
      userId: 'guest',
      unlocked: true,
    );
  }

  void signIn({required String email, String? userId}) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      onboardingComplete: true,
      email: email,
      userId: userId ?? email,
      unlocked: true,
    );
  }

  void signOut() {
    state = const Session(
      status: AuthStatus.unknown,
      splashDone: true,
      onboardingComplete: false,
    );
  }

  void setPinConfigured({required bool enabled}) {
    state = state.copyWith(pinSet: enabled, unlocked: !enabled);
  }

  void unlock() {
    state = state.copyWith(unlocked: true);
  }

  void lock() {
    if (state.pinSet) {
      state = state.copyWith(unlocked: false);
    }
  }

  void setBackupEnabled({required bool enabled}) {
    state = state.copyWith(backupEnabled: enabled);
  }
}

final sessionProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);
