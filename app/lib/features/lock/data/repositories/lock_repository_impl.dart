import 'package:doxan/features/lock/domain/repositories/lock_repository.dart';

class LockRepositoryImpl implements LockRepository {
  @override
  Future<void> setPin(String pin) async {}

  @override
  Future<bool> verifyPin(String pin) async => pin.length == 6;
}
