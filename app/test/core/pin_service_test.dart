import 'package:doxan/core/security/pin_hasher.dart';
import 'package:doxan/core/security/pin_service.dart';
import 'package:doxan/core/security/secure_store.dart';
import 'package:doxan/core/session/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guarda el PIN en secure storage y lo verifica', () async {
    final service = PinService(MemorySessionStore(), MemorySecureStore());
    expect(await service.hasPin(), isFalse);
    await service.setPin('123456');
    expect(await service.hasPin(), isTrue);
    expect(await service.verify('123456'), isTrue);
    expect(await service.verify('000000'), isFalse);
  });

  test('migra el hash legado a SecureStore', () async {
    final legacy = PinHasher.hashPin('654321', salt: 'legacy');
    final secure = MemorySecureStore();
    final service = PinService(
      MemorySessionStore(SessionPrefs(pinHash: legacy)),
      secure,
    );
    expect(await service.verify('654321'), isTrue);
    expect(await secure.read(SecureKeys.pinHash), legacy);
  });
}
