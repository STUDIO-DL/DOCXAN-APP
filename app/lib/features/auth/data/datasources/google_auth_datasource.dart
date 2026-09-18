import 'package:doxan/core/errors/app_failure.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDatasource {
  GoogleAuthDatasource({required this.webClientId});

  final String webClientId;

  Future<({String idToken, String? accessToken})> signIn() async {
    if (webClientId.isEmpty) {
      throw const AuthFailure(
        'Falta GOOGLE_WEB_CLIENT_ID. Es el Client ID de tipo Web, no el de Android.',
      );
    }

    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
      scopes: const ['email', 'profile'],
    );
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw const AuthCancelledFailure();
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthFailure(
        'Google no devolvió idToken. Revisa SHA-1, package name y el Client ID Web en Supabase.',
      );
    }
    return (idToken: idToken, accessToken: auth.accessToken);
  }

  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn(serverClientId: webClientId);
    await googleSignIn.signOut();
  }
}
