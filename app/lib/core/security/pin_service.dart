import 'package:docxan/core/security/pin_hasher.dart';
import 'package:docxan/core/security/secure_store.dart';
import 'package:docxan/core/session/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PinService {
  PinService(this._store, this._secure);

  final SessionStore _store;
  final SecureStore _secure;
  String? _verifiedPin;

  String? get verifiedPin => _verifiedPin;

  Future<bool> hasPin() async {
    final hash = await _readHash();
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final packed = PinHasher.hashPin(pin);
    await _secure.write(SecureKeys.pinHash, packed);
    final prefs = await _store.load();
    await _store.save(prefs.copyWith(pinHash: packed));
    _verifiedPin = pin;
  }

  Future<bool> verify(String pin) async {
    final stored = await _readHash();
    if (stored == null || stored.isEmpty) return false;
    final ok = PinHasher.verify(pin, stored);
    if (ok) _verifiedPin = pin;
    return ok;
  }

  Future<void> clear() async {
    _verifiedPin = null;
    await _secure.delete(SecureKeys.pinHash);
    final prefs = await _store.load();
    await _store.save(prefs.copyWith(clearPin: true, biometricsEnabled: false));
  }

  Future<String?> _readHash() async {
    final secure = await _secure.read(SecureKeys.pinHash);
    if (secure != null && secure.isNotEmpty) return secure;
    final prefs = await _store.load();
    final legacy = prefs.pinHash;
    if (legacy != null && legacy.isNotEmpty) {
      await _secure.write(SecureKeys.pinHash, legacy);
      return legacy;
    }
    return null;
  }
}

final pinServiceProvider = Provider<PinService>((ref) {
  return PinService(
    ref.watch(sessionStoreProvider),
    ref.watch(secureStoreProvider),
  );
});
