import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 PIN hash. Format: `pbkdf2$iterations$salt$hashHex`.
/// Legacy single-round hashes (`salt$hashHex`) still verify and should be
/// re-hashed on the next successful unlock.
abstract final class PinHasher {
  static const separator = r'$';
  static const scheme = 'pbkdf2';
  static const defaultIterations = 120000;

  static String randomSalt([int length = 16]) {
    final rng = Random.secure();
    final bytes = List<int>.generate(length, (_) => rng.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String hashPin(
    String pin, {
    String? salt,
    int iterations = defaultIterations,
  }) {
    final usedSalt = salt ?? randomSalt();
    final hash = _pbkdf2(pin, usedSalt, iterations);
    return [scheme, '$iterations', usedSalt, hash].join(separator);
  }

  static String legacyHashPin(String pin, {required String salt}) {
    return '$salt$separator${_legacyDigest(pin, salt)}';
  }

  static bool needsUpgrade(String stored) => !stored.startsWith('$scheme$separator');

  static String? saltOf(String stored) {
    final parts = stored.split(separator);
    if (parts.length == 4 && parts[0] == scheme) return parts[2];
    if (parts.length == 2 && parts[0].isNotEmpty) return parts[0];
    return null;
  }

  static bool verify(String pin, String stored) {
    final parts = stored.split(separator);
    if (parts.length == 4 && parts[0] == scheme) {
      final iterations = int.tryParse(parts[1]);
      if (iterations == null || iterations < 1 || parts[2].isEmpty) {
        return false;
      }
      return _equals(_pbkdf2(pin, parts[2], iterations), parts[3]);
    }
    if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return _equals(_legacyDigest(pin, parts[0]), parts[1]);
    }
    return false;
  }

  static String _legacyDigest(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  static String _pbkdf2(String pin, String salt, int iterations) {
    final hmac = Hmac(sha256, utf8.encode(pin));
    var block = hmac.convert([...utf8.encode(salt), 0, 0, 0, 1]).bytes;
    final out = List<int>.of(block);
    for (var i = 1; i < iterations; i++) {
      block = hmac.convert(block).bytes;
      for (var j = 0; j < out.length; j++) {
        out[j] ^= block[j];
      }
    }
    return out.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static bool _equals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
