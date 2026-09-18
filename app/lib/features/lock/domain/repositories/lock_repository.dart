abstract interface class LockRepository {
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
}
