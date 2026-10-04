import 'package:docxan/core/errors/app_failure.dart';
import 'package:docxan/core/network/docxan_supabase.dart';
import 'package:docxan/core/notifications/push_notifications.dart';
import 'package:docxan/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:docxan/features/auth/domain/entities/auth_user.dart';
import 'package:docxan/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.googleWebClientId});

  final String googleWebClientId;

  GoogleAuthDatasource get _google =>
      GoogleAuthDatasource(webClientId: googleWebClientId);

  @override
  bool get isConfigured => DocxanSupabase.isReady;

  @override
  bool get isGoogleConfigured =>
      DocxanSupabase.isReady && googleWebClientId.isNotEmpty;

  @override
  AuthUser? get currentUser =>
      _map(DocxanSupabase.isReady ? DocxanSupabase.client.auth.currentUser : null);

  @override
  Stream<AuthUser?> authChanges() {
    if (!DocxanSupabase.isReady) return const Stream.empty();
    return DocxanSupabase.client.auth.onAuthStateChange.map(
      (event) => _map(event.session?.user),
    );
  }

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    _ensureReady();
    try {
      final response = await DocxanSupabase.client.auth.signInWithPassword(
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
      final response = await DocxanSupabase.client.auth.signInWithIdToken(
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
      final response = await DocxanSupabase.client.auth.signUp(
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
    if (!DocxanSupabase.isReady) return;
    await PushNotifications.unregister();
    await DocxanSupabase.client.auth.signOut();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    _ensureReady();
    try {
      await DocxanSupabase.client.auth.resetPasswordForEmail(email);
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  void _ensureReady() {
    if (!DocxanSupabase.isReady) {
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
