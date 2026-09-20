import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:docxan/core/errors/app_failure.dart';

/// AES-256-GCM ciphertext with Argon2id key derived from the user PIN.
///
/// Layout: `DXN1 | salt(16) | nonce(12) | ciphertext | mac(16)`.
abstract final class BackupCrypto {
  static const magic = [0x44, 0x58, 0x4E, 0x31];
  static const saltLength = 16;
  static const nonceLength = 12;
  static const macLength = 16;
  static const headerLength = 4 + saltLength + nonceLength;

  static final _aes = AesGcm.with256bits();
  static final _kdf = Argon2id(
    parallelism: 1,
    memory: 8192,
    iterations: 2,
    hashLength: 32,
  );

  static Future<Uint8List> encrypt({
    required List<int> plaintext,
    required String pin,
  }) async {
    final salt = _randomBytes(saltLength);
    final key = await _derive(pin, salt);
    final box = await _aes.encrypt(plaintext, secretKey: key);
    return Uint8List.fromList([
      ...magic,
      ...salt,
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  static Future<Uint8List> decrypt({
    required List<int> blob,
    required String pin,
  }) async {
    if (blob.length < headerLength + macLength) {
      throw const CryptoFailure('El backup cifrado está incompleto.');
    }
    if (blob[0] != magic[0] ||
        blob[1] != magic[1] ||
        blob[2] != magic[2] ||
        blob[3] != magic[3]) {
      throw const CryptoFailure('El backup no es un blob Docxan.');
    }
    final salt = blob.sublist(4, 4 + saltLength);
    final nonce = blob.sublist(4 + saltLength, headerLength);
    final body = blob.sublist(headerLength);
    final cipherText = body.sublist(0, body.length - macLength);
    final mac = body.sublist(body.length - macLength);
    final key = await _derive(pin, salt);
    try {
      final clear = await _aes.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
      return Uint8List.fromList(clear);
    } catch (_) {
      throw const CryptoFailure(
        'No se pudo descifrar. El PIN no coincide con este backup.',
      );
    }
  }

  static Future<SecretKey> _derive(String pin, List<int> salt) {
    return _kdf.deriveKeyFromPassword(password: pin, nonce: salt);
  }

  static List<int> _randomBytes(int length) {
    final rng = Random.secure();
    return List<int>.generate(length, (_) => rng.nextInt(256));
  }
}
