import 'dart:convert';

import 'package:docxan/core/errors/app_failure.dart';
import 'package:docxan/core/security/backup_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = '11111111-2222-3333-4444-555555555555';
const _doc = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
final _pepper = List<int>.generate(32, (i) => i);
final _otherPepper = List<int>.generate(32, (i) => 255 - i);

Future<List<int>> _encryptV2(String text, {BackupKeyCache? cache}) {
  return BackupCrypto.encrypt(
    plaintext: utf8.encode(text),
    pin: '123456',
    pepper: _pepper,
    userId: _user,
    documentId: _doc,
    cache: cache,
  );
}

void main() {
  test('DXN2: cifra y descifra con PIN + pepper', () async {
    final blob = await _encryptV2('documento secreto');
    expect(blob.take(4), BackupCrypto.magicV2);
    expect(BackupCrypto.versionOf(blob), 2);
    final restored = await BackupCrypto.decrypt(
      blob: blob,
      pin: '123456',
      pepper: _pepper,
      userId: _user,
      documentId: _doc,
    );
    expect(utf8.decode(restored), 'documento secreto');
  });

  test('DXN2: la caché reutiliza la sal de subida y sigue descifrando', () async {
    final cache = BackupKeyCache();
    final a = await _encryptV2('uno', cache: cache);
    final b = await _encryptV2('dos', cache: cache);
    expect(a.sublist(4, 20), b.sublist(4, 20));
    final restored = await BackupCrypto.decrypt(
      blob: b,
      pin: '123456',
      pepper: _pepper,
      userId: _user,
      documentId: _doc,
      cache: cache,
    );
    expect(utf8.decode(restored), 'dos');
  });

  test('DXN2: rechaza PIN incorrecto', () async {
    final blob = await _encryptV2('hola');
    expect(
      () => BackupCrypto.decrypt(
        blob: blob,
        pin: '000000',
        pepper: _pepper,
        userId: _user,
        documentId: _doc,
      ),
      throwsA(isA<CryptoFailure>()),
    );
  });

  test('DXN2: rechaza pepper incorrecto', () async {
    final blob = await _encryptV2('hola');
    expect(
      () => BackupCrypto.decrypt(
        blob: blob,
        pin: '123456',
        pepper: _otherPepper,
        userId: _user,
        documentId: _doc,
      ),
      throwsA(isA<CryptoFailure>()),
    );
  });

  test('DXN2: rechaza otro documento u otro usuario (AAD)', () async {
    final blob = await _encryptV2('hola');
    expect(
      () => BackupCrypto.decrypt(
        blob: blob,
        pin: '123456',
        pepper: _pepper,
        userId: _user,
        documentId: 'ffffffff-bbbb-cccc-dddd-eeeeeeeeeeee',
      ),
      throwsA(isA<CryptoFailure>()),
    );
    expect(
      () => BackupCrypto.decrypt(
        blob: blob,
        pin: '123456',
        pepper: _pepper,
        userId: 'ffffffff-2222-3333-4444-555555555555',
        documentId: _doc,
      ),
      throwsA(isA<CryptoFailure>()),
    );
  });

  test('DXN2: sin pepper falla', () async {
    final blob = await _encryptV2('hola');
    expect(
      () => BackupCrypto.decrypt(blob: blob, pin: '123456'),
      throwsA(isA<CryptoFailure>()),
    );
  });

  test('DXN1 legado sigue descifrando solo con el PIN', () async {
    final blob = await BackupCrypto.encryptLegacyV1(
      plaintext: utf8.encode('backup antiguo'),
      pin: '123456',
    );
    expect(BackupCrypto.versionOf(blob), 1);
    final restored = await BackupCrypto.decrypt(blob: blob, pin: '123456');
    expect(utf8.decode(restored), 'backup antiguo');
    expect(
      () => BackupCrypto.decrypt(blob: blob, pin: '000000'),
      throwsA(isA<CryptoFailure>()),
    );
  });

  test('rechaza blobs que no son de Docxan', () async {
    expect(
      () => BackupCrypto.decrypt(blob: List<int>.filled(64, 7), pin: '123456'),
      throwsA(isA<CryptoFailure>()),
    );
  });
}
