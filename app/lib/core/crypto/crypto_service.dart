/// AES-256-GCM + Argon2id. Implementación real en semanas 2–3.
abstract interface class CryptoService {
  Future<List<int>> deriveKey(String pin);
  Future<List<int>> encrypt(List<int> plaintext, List<int> key);
  Future<List<int>> decrypt(List<int> ciphertext, List<int> key);
}

class UnimplementedCryptoService implements CryptoService {
  const UnimplementedCryptoService();

  @override
  Future<List<int>> deriveKey(String pin) {
    throw UnimplementedError('CryptoService: semana 2');
  }

  @override
  Future<List<int>> encrypt(List<int> plaintext, List<int> key) {
    throw UnimplementedError('CryptoService: semana 2');
  }

  @override
  Future<List<int>> decrypt(List<int> ciphertext, List<int> key) {
    throw UnimplementedError('CryptoService: semana 2');
  }
}
