abstract final class AppConstants {
  static const appName = 'Docxan';
  static const applicationId = 'app.docxan';
  static const splashDuration = Duration(milliseconds: 1400);
  static const pinLength = 6;
  static const trashRetentionDays = 30;
  static const targetPageBytesMin = 150 * 1024;
  static const targetPageBytesMax = 500 * 1024;
  static const privacyUrl = 'https://docxan.app/privacy';
  static const termsUrl = 'https://docxan.app/terms';
}

abstract final class StorageKeys {
  static const onboardingComplete = 'onboarding_complete';
  static const pinHash = 'pin_hash';
  static const backupEnabled = 'backup_enabled';
  static const biometricsEnabled = 'biometrics_enabled';
  static const guestMode = 'guest_mode';
  static const appLocale = 'app_locale';
}
