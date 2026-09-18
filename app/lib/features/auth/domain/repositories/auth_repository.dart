import 'package:doxan/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  bool get isConfigured;
  AuthUser? get currentUser;
  Stream<AuthUser?> authChanges();
  Future<AuthUser> signInWithEmail(String email, String password);
  Future<SignUpResult> signUp(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<AuthUser> signInWithGoogle();
  bool get isGoogleConfigured;
}
