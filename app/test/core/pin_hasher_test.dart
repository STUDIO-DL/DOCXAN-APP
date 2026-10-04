import 'package:docxan/core/security/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hash y verify coinciden con la misma sal', () {
    const pin = '123456';
    const salt = 'test-salt';
    final stored = PinHasher.hashPin(pin, salt: salt);
    expect(PinHasher.verify(pin, stored), isTrue);
    expect(PinHasher.verify('000000', stored), isFalse);
    expect(PinHasher.saltOf(stored), salt);
    expect(PinHasher.needsUpgrade(stored), isFalse);
  });

  test('sales distintas producen hashes distintos', () {
    const pin = '654321';
    final a = PinHasher.hashPin(pin, salt: 'aaa');
    final b = PinHasher.hashPin(pin, salt: 'bbb');
    expect(a, isNot(b));
    expect(PinHasher.verify(pin, a), isTrue);
    expect(PinHasher.verify(pin, b), isTrue);
  });

  test('el hash legado sigue verificando y pide actualización', () {
    final legacy = PinHasher.legacyHashPin('123456', salt: 'old');
    expect(PinHasher.verify('123456', legacy), isTrue);
    expect(PinHasher.verify('000000', legacy), isFalse);
    expect(PinHasher.needsUpgrade(legacy), isTrue);
  });

  test('formato inválido no verifica', () {
    expect(PinHasher.verify('123456', 'sin-separador'), isFalse);
    expect(PinHasher.verify('123456', r'$solo'), isFalse);
    expect(PinHasher.verify('123456', r'pbkdf2$0$s$h'), isFalse);
  });
}
