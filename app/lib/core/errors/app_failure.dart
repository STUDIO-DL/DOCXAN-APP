sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Sin conexión']);
}

class CryptoFailure extends AppFailure {
  const CryptoFailure([super.message = 'Error de cifrado']);
}

class StorageFailure extends AppFailure {
  const StorageFailure([super.message = 'Error de almacenamiento']);
}

class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'No se pudo completar el acceso']);
}

class AuthCancelledFailure extends AppFailure {
  const AuthCancelledFailure() : super('cancelled');
}
