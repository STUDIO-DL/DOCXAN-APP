class AuthUser {
  const AuthUser({required this.id, this.email});

  final String id;
  final String? email;
}

class SignUpResult {
  const SignUpResult({required this.needsEmailConfirmation, this.user});

  final bool needsEmailConfirmation;
  final AuthUser? user;
}
