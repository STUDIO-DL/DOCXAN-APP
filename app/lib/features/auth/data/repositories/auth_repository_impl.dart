import 'package:doxan/core/errors/app_failure.dart';
import 'package:doxan/core/network/doxan_supabase.dart';
import 'package:doxan/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:doxan/features/auth/domain/entities/auth_user.dart';
import 'package:doxan/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.googleWebClientId});

  final String googleWebClientId;

  GoogleAuthDatasource get _google =>
      GoogleAuthDatasource(webClientId: googleWebClientId);

  @override
  bool get isConfigured => DoxanSupabase.isReady;

  @override
  bool get isGoogleConfigured =>
      DoxanSupabase.isReady && googleWebClientId.isNotEmpty;

  @override
  AuthUser? get currentUser =>
      _map(DoxanSupabase.isReady ? DoxanSupabase.client.auth.currentUser : null);

  @override
  Stream<AuthUser?> authChanges() {
    if (!DoxanSupabase.isReady) return const Stream.empty();
    return DoxanSupabase.client.auth.onAuthStateChange.map(
      (event) => _map(event.session?.user),
    );
  }

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    _ensureReady();
    try {
      final response = await DoxanSupabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = _map(response.user);
      if (user == null) {
        throw const AuthFailure();
      }
      return user;
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    _ensureReady();
    final tokens = await _google.signIn();
    try {
      final response = await DoxanSupabase.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: tokens.idToken,
        accessToken: tokens.accessToken,
      );
      final user = _map(response.user);
      if (user == null) {
        throw const AuthFailure();
      }
      return user;
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<SignUpResult> signUp(String email, String password) async {
    _ensureReady();
    try {
      final response = await DoxanSupabase.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = _map(response.user);
      return SignUpResult(
        needsEmailConfirmation: response.session == null,
        user: user,
      );
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<void> signOut() async {
    if (googleWebClientId.isNotEmpty) {
      await _google.signOut();
    }
    if (!DoxanSupabase.isReady) return;
    await DoxanSupabase.client.auth.signOut();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    _ensureReady();
    try {
      await DoxanSupabase.client.auth.resetPasswordForEmail(email);
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  void _ensureReady() {
    if (!DoxanSupabase.isReady) {
      throw const AuthFailure(
        'Supabase no está configurado. Crea app/env.json y relanza.',
      );
    }
  }

  AuthUser? _map(User? user) {
    if (user == null) return null;
    return AuthUser(id: user.id, email: user.email);
  }
}
