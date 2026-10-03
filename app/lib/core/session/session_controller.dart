import 'package:docxan/core/session/session.dart';
import 'package:docxan/core/session/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionController extends Notifier<Session> {
  bool _ignoreNextLock = false;
  DateTime? _pausedAt;

  @override
  Session build() => const Session(status: AuthStatus.unknown);

  Future<void> hydrate() async {
    try {
      final prefs = await ref.read(sessionStoreProvider).load();
      state = state.copyWith(
        onboardingComplete: prefs.onboardingComplete,
        pinSet: prefs.pinSet,
        biometricsEnabled: prefs.biometricsEnabled,
        unlocked: !prefs.pinSet,
        status: prefs.guestMode ? AuthStatus.guest : state.status,
        userId: prefs.guestMode ? 'guest' : state.userId,
      );
    } catch (_) {
      // Tests and missing plugins keep the in-memory defaults.
    }
  }

  Future<void> _persist() async {
    final store = ref.read(sessionStoreProvider);
    final current = await store.load();
    await store.save(
      current.copyWith(
        onboardingComplete: state.onboardingComplete,
        biometricsEnabled: state.biometricsEnabled,
        guestMode: state.isGuest,
        pinHash: current.pinHash,
        clearPin: !state.pinSet && current.pinHash != null,
      ),
    );
  }

  void finishSplash() {
    state = state.copyWith(splashDone: true);
  }

  void enterAsGuest() {
    state = state.copyWith(
      status: AuthStatus.guest,
      onboardingComplete: true,
      userId: 'guest',
      unlocked: !state.pinSet || state.unlocked,
    );
    _persist();
  }

  void signIn({required String email, String? userId}) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      onboardingComplete: true,
      email: email,
      userId: userId ?? email,
      unlocked: state.pinSet ? state.unlocked : true,
    );
    _persist();
  }

  void signOut() {
    state = Session(
      status: AuthStatus.unknown,
      splashDone: true,
      onboardingComplete: false,
      pinSet: state.pinSet,
      biometricsEnabled: state.biometricsEnabled,
      unlocked: !state.pinSet,
    );
    _persist();
  }

  void setPinConfigured({required bool enabled}) {
    state = state.copyWith(pinSet: enabled, unlocked: enabled ? true : true);
    _persist();
  }

  void setBiometricsEnabled({required bool enabled}) {
    state = state.copyWith(biometricsEnabled: enabled);
    _persist();
  }

  void unlock() {
    state = state.copyWith(unlocked: true);
  }

  void lock() {
    if (state.pinSet) {
      state = state.copyWith(unlocked: false);
    }
  }

  void ignoreNextLock() {
    _ignoreNextLock = true;
  }

  void clearIgnoreNextLock() {
    _ignoreNextLock = false;
  }

  void onAppPaused() {
    _pausedAt = DateTime.now();
  }

  void onAppResumed() {
    if (_ignoreNextLock) {
      _ignoreNextLock = false;
      _pausedAt = null;
      return;
    }
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null) return;
    if (DateTime.now().difference(pausedAt) >= const Duration(seconds: 2)) {
      lock();
    }
  }

  void setBackupEnabled({required bool enabled}) {
    state = state.copyWith(backupEnabled: enabled);
  }
}

final sessionProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);
