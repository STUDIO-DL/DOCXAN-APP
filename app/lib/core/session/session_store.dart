import 'package:doxan/core/constants/app_constants.dart';
import 'package:doxan/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionPrefs {
  const SessionPrefs({
    this.onboardingComplete = false,
    this.pinHash,
    this.biometricsEnabled = false,
    this.guestMode = false,
  });

  final bool onboardingComplete;
  final String? pinHash;
  final bool biometricsEnabled;
  final bool guestMode;

  bool get pinSet => pinHash != null && pinHash!.isNotEmpty;

  SessionPrefs copyWith({
    bool? onboardingComplete,
    String? pinHash,
    bool? biometricsEnabled,
    bool? guestMode,
    bool clearPin = false,
  }) {
    return SessionPrefs(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      pinHash: clearPin ? null : (pinHash ?? this.pinHash),
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      guestMode: guestMode ?? this.guestMode,
    );
  }
}

abstract interface class SessionStore {
  Future<SessionPrefs> load();
  Future<void> save(SessionPrefs prefs);
}

class MemorySessionStore implements SessionStore {
  MemorySessionStore([this.value = const SessionPrefs()]);

  SessionPrefs value;

  @override
  Future<SessionPrefs> load() async => value;

  @override
  Future<void> save(SessionPrefs prefs) async {
    value = prefs;
  }
}

class PrefsSessionStore implements SessionStore {
  @override
  Future<SessionPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return SessionPrefs(
        onboardingComplete:
            prefs.getBool(StorageKeys.onboardingComplete) ?? false,
        pinHash: prefs.getString(StorageKeys.pinHash),
        biometricsEnabled: prefs.getBool(StorageKeys.biometricsEnabled) ?? false,
        guestMode: prefs.getBool(StorageKeys.guestMode) ?? false,
      );
    } catch (error) {
      AppLogger.debug('Session prefs load skipped: $error');
      return const SessionPrefs();
    }
  }

  @override
  Future<void> save(SessionPrefs prefs) async {
    try {
      final store = await SharedPreferences.getInstance();
      await store.setBool(StorageKeys.onboardingComplete, prefs.onboardingComplete);
      await store.setBool(StorageKeys.biometricsEnabled, prefs.biometricsEnabled);
      await store.setBool(StorageKeys.guestMode, prefs.guestMode);
      if (prefs.pinHash == null || prefs.pinHash!.isEmpty) {
        await store.remove(StorageKeys.pinHash);
      } else {
        await store.setString(StorageKeys.pinHash, prefs.pinHash!);
      }
    } catch (error) {
      AppLogger.debug('Session prefs save skipped: $error');
    }
  }
}

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return PrefsSessionStore();
});
