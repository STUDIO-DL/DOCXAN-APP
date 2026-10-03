import 'dart:convert';

import 'package:docxan/core/security/pin_hasher.dart';
import 'package:docxan/core/security/secure_store.dart';
import 'package:docxan/core/session/session_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _hashPin(String pin) => PinHasher.hashPin(pin);

bool _verifyPin((String, String) args) => PinHasher.verify(args.$1, args.$2);

/// Result of a PIN attempt. [lockout] > 0 means further attempts are
/// refused for that long (either already locked, or this failure tripped it).
class PinCheck {
  const PinCheck({required this.ok, this.lockout = Duration.zero});

  final bool ok;
  final Duration lockout;

  bool get lockedOut => lockout > Duration.zero;
}

class PinService {
  PinService(this._store, this._secure, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// Stored in SharedPreferences only to flag that a PIN exists; the hash
  /// itself lives exclusively in [SecureStore].
  static const prefsMarker = 'secure';

  /// Consecutive failures allowed before the first lockout.
  static const freeAttempts = 5;

  /// Lockout after failure #5, #6, #7, #8 and #9+ respectively.
  static const lockoutSchedule = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(hours: 1),
  ];

  final SessionStore _store;
  final SecureStore _secure;
  final DateTime Function() _clock;
  String? _verifiedPin;
  _Attempts? _attempts;

  String? get verifiedPin => _verifiedPin;

  static Duration lockoutAfter(int failures) {
    if (failures < freeAttempts) return Duration.zero;
    final index = (failures - freeAttempts).clamp(0, lockoutSchedule.length - 1);
    return lockoutSchedule[index];
  }

  Future<bool> hasPin() async {
    final hash = await _readHash();
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final packed = await compute(_hashPin, pin);
    await _secure.write(SecureKeys.pinHash, packed);
    final prefs = await _store.load();
    await _store.save(prefs.copyWith(pinHash: prefsMarker));
    _verifiedPin = pin;
    await resetAttempts();
  }

  /// Time left before another PIN attempt is accepted.
  Future<Duration> remainingLockout() async {
    final attempts = await _loadAttempts();
    return _remaining(attempts);
  }

  /// Verifies [pin] honouring the persistent attempt counter and lockout.
  Future<PinCheck> check(String pin) async {
    final attempts = await _loadAttempts();
    final remaining = _remaining(attempts);
    if (remaining > Duration.zero) {
      return PinCheck(ok: false, lockout: remaining);
    }
    final stored = await _readHash();
    if (stored == null || stored.isEmpty) return const PinCheck(ok: false);
    final ok = await compute(_verifyPin, (pin, stored));
    if (!ok) {
      final failures = attempts.failures + 1;
      final lockout = lockoutAfter(failures);
      final until = lockout > Duration.zero
          ? _clock().add(lockout).millisecondsSinceEpoch
          : 0;
      await _saveAttempts(_Attempts(failures, until));
      return PinCheck(ok: false, lockout: lockout);
    }
    _verifiedPin = pin;
    await resetAttempts();
    if (PinHasher.needsUpgrade(stored)) {
      await _secure.write(SecureKeys.pinHash, await compute(_hashPin, pin));
    }
    return const PinCheck(ok: true);
  }

  Future<bool> verify(String pin) async => (await check(pin)).ok;

  /// Clears the failure counter, e.g. after a successful biometric unlock.
  Future<void> resetAttempts() async {
    final current = _attempts;
    if (current != null && current.failures == 0 && current.lockedUntil == 0) {
      return;
    }
    await _saveAttempts(const _Attempts(0, 0));
  }

  Future<void> clear() async {
    _verifiedPin = null;
    await _secure.delete(SecureKeys.pinHash);
    _attempts = const _Attempts(0, 0);
    await _secure.delete(SecureKeys.pinAttempts);
    final prefs = await _store.load();
    await _store.save(prefs.copyWith(clearPin: true, biometricsEnabled: false));
  }

  Duration _remaining(_Attempts attempts) {
    if (attempts.lockedUntil <= 0) return Duration.zero;
    final left = Duration(
      milliseconds: attempts.lockedUntil - _clock().millisecondsSinceEpoch,
    );
    if (left <= Duration.zero) return Duration.zero;
    // Device clock moved backwards: never wait longer than the cap.
    final cap = lockoutAfter(attempts.failures);
    return left > cap ? cap : left;
  }

  Future<_Attempts> _loadAttempts() async {
    final cached = _attempts;
    if (cached != null) return cached;
    final raw = await _secure.read(SecureKeys.pinAttempts);
    final loaded = _Attempts.decode(raw);
    _attempts = loaded;
    return loaded;
  }

  Future<void> _saveAttempts(_Attempts attempts) async {
    _attempts = attempts;
    await _secure.write(SecureKeys.pinAttempts, attempts.encode());
  }

  Future<String?> _readHash() async {
    final secure = await _secure.read(SecureKeys.pinHash);
    final prefs = await _store.load();
    final legacy = prefs.pinHash;
    if (secure != null && secure.isNotEmpty) {
      if (legacy != null && legacy.isNotEmpty && legacy != prefsMarker) {
        await _store.save(prefs.copyWith(pinHash: prefsMarker));
      }
      return secure;
    }
    if (legacy != null && legacy.isNotEmpty && legacy != prefsMarker) {
      await _secure.write(SecureKeys.pinHash, legacy);
      await _store.save(prefs.copyWith(pinHash: prefsMarker));
      return legacy;
    }
    return null;
  }
}

class _Attempts {
  const _Attempts(this.failures, this.lockedUntil);

  final int failures;

  /// Epoch milliseconds; 0 when not locked.
  final int lockedUntil;

  String encode() => jsonEncode({'f': failures, 'u': lockedUntil});

  static _Attempts decode(String? raw) {
    if (raw == null || raw.isEmpty) return const _Attempts(0, 0);
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return const _Attempts(0, 0);
      final failures = map['f'];
      final until = map['u'];
      return _Attempts(
        failures is int && failures > 0 ? failures : 0,
        until is int && until > 0 ? until : 0,
      );
    } catch (_) {
      return const _Attempts(0, 0);
    }
  }
}

final pinServiceProvider = Provider<PinService>((ref) {
  return PinService(
    ref.watch(sessionStoreProvider),
    ref.watch(secureStoreProvider),
  );
});
