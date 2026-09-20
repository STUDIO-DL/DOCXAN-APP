import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted SHA-256 PIN hash. Format: `salt$hashHex`.
abstract final class PinHasher {
  static const separator = r'$';

  static String randomSalt([int length = 16]) {
    final rng = Random.secure();
    final bytes = List<int>.generate(length, (_) => rng.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String digest(String pin, {required String salt}) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  static String pack({required String salt, required String hash}) {
    return '$salt$separator$hash';
  }

  static String hashPin(String pin, {String? salt}) {
    final usedSalt = salt ?? randomSalt();
    return pack(salt: usedSalt, hash: digest(pin, salt: usedSalt));
  }

  static (String salt, String hash)? unpack(String stored) {
    final index = stored.indexOf(separator);
    if (index <= 0 || index == stored.length - 1) return null;
    return (stored.substring(0, index), stored.substring(index + 1));
  }

  static bool verify(String pin, String stored) {
    final parts = unpack(stored);
    if (parts == null) return false;
    return digest(pin, salt: parts.$1) == parts.$2;
  }
}
