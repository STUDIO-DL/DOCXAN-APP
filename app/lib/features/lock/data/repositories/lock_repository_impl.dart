import 'package:doxan/core/security/pin_service.dart';
import 'package:doxan/core/security/secure_store.dart';
import 'package:doxan/core/session/session_store.dart';
import 'package:doxan/features/lock/domain/repositories/lock_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockRepositoryImpl implements LockRepository {
  LockRepositoryImpl({PinService? pin})
    : _pin = pin ?? PinService(PrefsSessionStore(), MemorySecureStore());

  final PinService _pin;

  @override
  Future<void> setPin(String pin) => _pin.setPin(pin);

  @override
  Future<bool> verifyPin(String pin) => _pin.verify(pin);
}

final lockRepositoryProvider = Provider<LockRepository>((ref) {
  return LockRepositoryImpl(pin: ref.watch(pinServiceProvider));
});
