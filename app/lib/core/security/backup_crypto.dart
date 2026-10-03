import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:docxan/core/errors/app_failure.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// AES-256-GCM backup blobs.
///
/// DXN2 (current): `DXN2 | salt(16) | nonce(12) | ciphertext | mac(16)`.
/// Key = HKDF-SHA256(ikm: Argon2id(PIN, salt) ‖ pepper, salt: salt,
/// info: `docxan-backup-v2|userId|documentId`). The pepper is a per-user
/// 32-byte secret held by the server (Edge Function `backup_key`), so a
/// stolen blob cannot be brute-forced offline from the PIN alone. AAD binds
/// the ciphertext to the version, the user and the remote document id.
///
/// DXN1 (legacy, decrypt only): `DXN1 | salt(16) | nonce(12) | ct | mac(16)`,
/// key = Argon2id(PIN, salt) with 8 MiB / 2 iterations.
abstract final class BackupCrypto {
  static const magicV1 = [0x44, 0x58, 0x4E, 0x31];
  static const magicV2 = [0x44, 0x58, 0x4E, 0x32];
  static const magic = magicV2;
  static const saltLength = 16;
  static const nonceLength = 12;
  static const macLength = 16;
  static const pepperLength = 32;
  static const headerLength = 4 + saltLength + nonceLength;

  static const _v1Memory = 8192;
  static const _v1Iterations = 2;
  static const _v2Memory = 19456;
  static const _v2Iterations = 2;

  static final _aes = AesGcm.with256bits();
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  /// Returns 1 or 2 for Docxan blobs, `null` otherwise.
  static int? versionOf(List<int> blob) {
    if (blob.length < 4) return null;
    if (_startsWith(blob, magicV2)) return 2;
    if (_startsWith(blob, magicV1)) return 1;
    return null;
  }

  static Future<Uint8List> encrypt({
    required List<int> plaintext,
    required String pin,
    required List<int> pepper,
    required String userId,
    required String documentId,
    BackupKeyCache? cache,
  }) async {
    _checkPepper(pepper);
    final salt = cache?.uploadSalt ?? _randomBytes(saltLength);
    final key = await _deriveV2(
      pin: pin,
      salt: salt,
      pepper: pepper,
      userId: userId,
      documentId: documentId,
      cache: cache,
    );
    final box = await _aes.encrypt(
      plaintext,
      secretKey: key,
      aad: _aadV2(userId, documentId),
    );
    return Uint8List.fromList([
      ...magicV2,
      ...salt,
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  /// Decrypts DXN2 (needs [pepper], [userId], [documentId]) or legacy DXN1.
  static Future<Uint8List> decrypt({
    required List<int> blob,
    required String pin,
    List<int>? pepper,
    String? userId,
    String? documentId,
    BackupKeyCache? cache,
  }) async {
    if (blob.length < headerLength + macLength) {
      throw const CryptoFailure('El backup cifrado está incompleto.');
    }
    final version = versionOf(blob);
    if (version == null) {
      throw const CryptoFailure('El backup no es un blob Docxan.');
    }
    final salt = blob.sublist(4, 4 + saltLength);
    final nonce = blob.sublist(4 + saltLength, headerLength);
    final body = blob.sublist(headerLength);
    final cipherText = body.sublist(0, body.length - macLength);
    final mac = body.sublist(body.length - macLength);

    final SecretKey key;
    final List<int> aad;
    if (version == 2) {
      if (pepper == null || userId == null || documentId == null) {
        throw const CryptoFailure('Falta la clave del servidor para este backup.');
      }
      _checkPepper(pepper);
      key = await _deriveV2(
        pin: pin,
        salt: salt,
        pepper: pepper,
        userId: userId,
        documentId: documentId,
        cache: cache,
      );
      aad = _aadV2(userId, documentId);
    } else {
      key = SecretKey(
        await _argon(pin, salt, _v1Memory, _v1Iterations, cache: cache),
      );
      aad = const <int>[];
    }

    try {
      final clear = await _aes.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
        aad: aad,
      );
      return Uint8List.fromList(clear);
    } catch (_) {
      throw const CryptoFailure(
        'No se pudo descifrar. El PIN no coincide con este backup.',
      );
    }
  }

  /// Produces a legacy DXN1 blob. Only used to test backward compatibility.
  @visibleForTesting
  static Future<Uint8List> encryptLegacyV1({
    required List<int> plaintext,
    required String pin,
  }) async {
    final salt = _randomBytes(saltLength);
    final key = SecretKey(await _argon(pin, salt, _v1Memory, _v1Iterations));
    final box = await _aes.encrypt(plaintext, secretKey: key);
    return Uint8List.fromList([
      ...magicV1,
      ...salt,
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  static Future<SecretKey> _deriveV2({
    required String pin,
    required List<int> salt,
    required List<int> pepper,
    required String userId,
    required String documentId,
    BackupKeyCache? cache,
  }) async {
    final stretched = await _argon(
      pin,
      salt,
      _v2Memory,
      _v2Iterations,
      cache: cache,
    );
    return _hkdf.deriveKey(
      secretKey: SecretKey([...stretched, ...pepper]),
      nonce: salt,
      info: utf8.encode(
        'docxan-backup-v2|${_norm(userId)}|${_norm(documentId)}',
      ),
    );
  }

  static List<int> _aadV2(String userId, String documentId) {
    return [
      ...magicV2,
      ...utf8.encode('|${_norm(userId)}|${_norm(documentId)}'),
    ];
  }

  static Future<Uint8List> _argon(
    String pin,
    List<int> salt,
    int memory,
    int iterations, {
    BackupKeyCache? cache,
  }) async {
    final cacheKey = '$memory:$iterations:${base64Encode(salt)}';
    final cached = cache?._lookup(pin, cacheKey);
    if (cached != null) return cached;
    final out = await _argonInIsolate(
      pin,
      Uint8List.fromList(salt),
      memory,
      iterations,
    );
    cache?._store(pin, cacheKey, out);
    return out;
  }

  static void _checkPepper(List<int> pepper) {
    if (pepper.length != pepperLength) {
      throw const CryptoFailure('La clave del servidor no es válida.');
    }
  }

  static String _norm(String id) => id.trim().toLowerCase();

  static bool _startsWith(List<int> blob, List<int> prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (blob[i] != prefix[i]) return false;
    }
    return true;
  }

  static List<int> _randomBytes(int length) {
    final rng = Random.secure();
    return List<int>.generate(length, (_) => rng.nextInt(256));
  }
}

/// Short-lived cache of Argon2id outputs for one sync/restore run.
///
/// Uploads in the same run share [uploadSalt], so the expensive Argon2id
/// step runs once per run instead of once per document. Drop the instance
/// (or call [clear]) when the run ends.
class BackupKeyCache {
  BackupKeyCache() : uploadSalt = BackupCrypto._randomBytes(BackupCrypto.saltLength);

  final List<int> uploadSalt;
  final Map<String, Uint8List> _entries = {};
  String? _pin;

  Uint8List? _lookup(String pin, String key) {
    if (_pin != pin) return null;
    return _entries[key];
  }

  void _store(String pin, String key, Uint8List value) {
    if (_pin != pin) {
      _entries.clear();
      _pin = pin;
    }
    _entries[key] = value;
  }

  void clear() {
    _entries.clear();
    _pin = null;
  }
}

Future<Uint8List> _argonInIsolate(
  String pin,
  Uint8List salt,
  int memory,
  int iterations,
) {
  return Isolate.run(() => _argon2id(pin, salt, memory, iterations));
}

Future<Uint8List> _argon2id(
  String pin,
  Uint8List salt,
  int memory,
  int iterations,
) async {
  final kdf = Argon2id(
    parallelism: 1,
    memory: memory,
    iterations: iterations,
    hashLength: 32,
  );
  final key = await kdf.deriveKeyFromPassword(password: pin, nonce: salt);
  return Uint8List.fromList(await key.extractBytes());
}
