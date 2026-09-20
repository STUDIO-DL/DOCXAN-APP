enum AuthStatus { unknown, guest, authenticated }

class Session {
  const Session({
    required this.status,
    this.splashDone = false,
    this.onboardingComplete = false,
    this.userId,
    this.email,
    this.pinSet = false,
    this.unlocked = true,
    this.backupEnabled = false,
    this.biometricsEnabled = false,
  });

  final AuthStatus status;
  final bool splashDone;
  final bool onboardingComplete;
  final String? userId;
  final String? email;
  final bool pinSet;
  final bool unlocked;
  final bool backupEnabled;
  final bool biometricsEnabled;

  bool get isGuest => status == AuthStatus.guest;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  Session copyWith({
    AuthStatus? status,
    bool? splashDone,
    bool? onboardingComplete,
    String? userId,
    String? email,
    bool? pinSet,
    bool? unlocked,
    bool? backupEnabled,
    bool? biometricsEnabled,
  }) {
    return Session(
      status: status ?? this.status,
      splashDone: splashDone ?? this.splashDone,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      pinSet: pinSet ?? this.pinSet,
      unlocked: unlocked ?? this.unlocked,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}
