import 'dart:convert';

import 'package:doxan/core/errors/app_failure.dart';
import 'package:doxan/core/security/backup_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cifra y descifra un blob con el PIN', () async {
    final clear = utf8.encode('documento secreto');
    final blob = await BackupCrypto.encrypt(plaintext: clear, pin: '123456');
    expect(blob.take(4), BackupCrypto.magic);
    final restored = await BackupCrypto.decrypt(blob: blob, pin: '123456');
    expect(utf8.decode(restored), 'documento secreto');
  });

  test('rechaza un PIN incorrecto', () async {
    final blob = await BackupCrypto.encrypt(
      plaintext: utf8.encode('hola'),
      pin: '123456',
    );
    expect(
      () => BackupCrypto.decrypt(blob: blob, pin: '000000'),
      throwsA(isA<CryptoFailure>()),
    );
  });
}
