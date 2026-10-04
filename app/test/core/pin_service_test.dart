import 'package:docxan/core/security/pin_hasher.dart';
import 'package:docxan/core/security/pin_service.dart';
import 'package:docxan/core/security/secure_store.dart';
import 'package:docxan/core/session/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guarda el PIN en secure storage y lo verifica', () async {
    final store = MemorySessionStore();
    final service = PinService(store, MemorySecureStore());
    expect(await service.hasPin(), isFalse);
    await service.setPin('123456');
    expect(await service.hasPin(), isTrue);
    expect(await service.verify('123456'), isTrue);
    expect(await service.verify('000000'), isFalse);
    expect(store.value.pinHash, PinService.prefsMarker);
  });

  test('migra el hash legado a SecureStore y lo actualiza', () async {
    final legacy = PinHasher.legacyHashPin('654321', salt: 'legacy');
    final secure = MemorySecureStore();
    final store = MemorySessionStore(SessionPrefs(pinHash: legacy));
    final service = PinService(store, secure);
    expect(await service.verify('654321'), isTrue);
    final upgraded = await secure.read(SecureKeys.pinHash);
    expect(PinHasher.needsUpgrade(upgraded!), isFalse);
    expect(PinHasher.verify('654321', upgraded), isTrue);
    expect(store.value.pinHash, PinService.prefsMarker);
  });

  test('calendario de bloqueo escalonado con tope de 1 h', () {
    expect(PinService.lockoutAfter(4), Duration.zero);
    expect(PinService.lockoutAfter(5), const Duration(seconds: 30));
    expect(PinService.lockoutAfter(6), const Duration(minutes: 1));
    expect(PinService.lockoutAfter(7), const Duration(minutes: 5));
    expect(PinService.lockoutAfter(8), const Duration(minutes: 15));
    expect(PinService.lockoutAfter(9), const Duration(hours: 1));
    expect(PinService.lockoutAfter(50), const Duration(hours: 1));
  });

  test('bloquea tras 5 fallos, sobrevive a reinicios y escala', () async {
    var now = DateTime(2026, 1, 1, 12);
    final secure = MemorySecureStore();
    final store = MemorySessionStore();
    final service = PinService(store, secure, clock: () => now);
    await service.setPin('123456');

    for (var i = 0; i < 4; i++) {
      final result = await service.check('000000');
      expect(result.ok, isFalse);
      expect(result.lockedOut, isFalse);
    }
    final fifth = await service.check('000000');
    expect(fifth.lockout, const Duration(seconds: 30));

    // Even the right PIN is refused while locked, and nothing is verified.
    final blocked = await service.check('123456');
    expect(blocked.ok, isFalse);
    expect(blocked.lockedOut, isTrue);

    // A fresh instance (app restart) still sees the lockout.
    final restarted = PinService(store, secure, clock: () => now);
    expect(await restarted.remainingLockout(), const Duration(seconds: 30));

    now = now.add(const Duration(seconds: 31));
    final sixth = await restarted.check('000000');
    expect(sixth.lockout, const Duration(minutes: 1));

    now = now.add(const Duration(minutes: 2));
    expect(await restarted.check('123456'), isA<PinCheck>().having(
      (check) => check.ok,
      'ok',
      isTrue,
    ));
    expect(await restarted.remainingLockout(), Duration.zero);
    expect((await restarted.check('000000')).lockedOut, isFalse);
  });

  test('resetAttempts (biometría) limpia el contador', () async {
    final now = DateTime(2026, 1, 1, 12);
    final service = PinService(
      MemorySessionStore(),
      MemorySecureStore(),
      clock: () => now,
    );
    await service.setPin('123456');
    for (var i = 0; i < 5; i++) {
      await service.check('000000');
    }
    expect(await service.remainingLockout(), greaterThan(Duration.zero));
    await service.resetAttempts();
    expect(await service.remainingLockout(), Duration.zero);
    expect(await service.verify('123456'), isTrue);
  });

  test('un reloj atrasado no alarga el bloqueo más allá del tope', () async {
    var now = DateTime(2026, 1, 1, 12);
    final service = PinService(
      MemorySessionStore(),
      MemorySecureStore(),
      clock: () => now,
    );
    await service.setPin('123456');
    for (var i = 0; i < 5; i++) {
      await service.check('000000');
    }
    now = now.subtract(const Duration(days: 30));
    expect(await service.remainingLockout(), const Duration(seconds: 30));
  });
}
