// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Docxan';

  @override
  String get splashTagline => 'Clean documents, on your phone.';

  @override
  String get onboardingTitle => 'Turn paper into digital documents';

  @override
  String get onboardingBody => 'Scan, enhance, and organize from your phone. OCR and saving work without Internet. Your files stay on the device unless you turn on encrypted backup.';

  @override
  String get onboardingPrivacy => 'Privacy first: nothing is uploaded in the clear. If you forget your PIN, an end-to-end backup cannot be recovered.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get getStarted => 'Get started';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get continueAsGuest => 'Browse without an account';

  @override
  String get guestBanner => 'You are in guest mode. Create an account to sync and back up.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get searchDocuments => 'Search documents...';

  @override
  String get searchTitle => 'Search';

  @override
  String get homeSubtitle => 'Your documents, always with you. Scan, organize, and open them whenever you need.';

  @override
  String get viewAll => 'View all';

  @override
  String get recentDocuments => 'Recent documents';

  @override
  String get recentFolders => 'Recent folders';

  @override
  String storageUsed(String used, String total) {
    return '$used of $total';
  }

  @override
  String get addNewFolder => 'Add new folder';

  @override
  String get folderName => 'Folder name';

  @override
  String get folderNameHint => 'e.g. Personal';

  @override
  String get createFolder => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get folderNameEmpty => 'Enter a name.';

  @override
  String get folderExists => 'A folder with that name already exists.';

  @override
  String get fileType => 'File type';

  @override
  String get tags => 'Tags';

  @override
  String get date => 'Date';

  @override
  String get urgent => 'Urgent';

  @override
  String get pending => 'Pending';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get lastMonth => 'Last month';

  @override
  String get accountAndProfile => 'Account and profile';

  @override
  String get storagePlan => 'Storage plan';

  @override
  String get personalData => 'Personal data';

  @override
  String get documentsSection => 'Documents';

  @override
  String get ocrLanguage => 'OCR languages';

  @override
  String get defaultFormat => 'Default formats';

  @override
  String get application => 'Application';

  @override
  String get securityAndPrivacy => 'Security and privacy';

  @override
  String get notifications => 'Notifications';

  @override
  String get themeAndAppearance => 'Theme (dark/light)';

  @override
  String get totalStorage => 'Total storage';

  @override
  String get viewDetails => 'View details';

  @override
  String get recents => 'Recents';

  @override
  String get folders => 'Folders';

  @override
  String get scan => 'Scan';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get searchTab => 'Search';

  @override
  String get scanCta => 'Scan';

  @override
  String get scanPlaceholderTitle => 'Point at the document';

  @override
  String get scanPlaceholderBody => 'The camera, crop, and OCR connect in week 2. This viewer marks the capture flow.';

  @override
  String get scanDocument => 'Scan document';

  @override
  String get editDocument => 'Edit document';

  @override
  String get placeDocumentInFrame => 'Place the document inside the frame.';

  @override
  String get flash => 'Flash';

  @override
  String get gallery => 'Gallery';

  @override
  String get auto => 'Auto';

  @override
  String get manual => 'Manual';

  @override
  String get autoDetectionSoon => 'Automatic detection will be available later. Use Manual to crop.';

  @override
  String get crop => 'Crop';

  @override
  String get rotate => 'Rotate';

  @override
  String get brightness => 'Brightness';

  @override
  String get contrast => 'Contrast';

  @override
  String get filters => 'Filters';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterDocument => 'Document';

  @override
  String get filterBw => 'Black and white';

  @override
  String get filterColor => 'Color';

  @override
  String get addAnotherPage => 'Add another page';

  @override
  String get addAnotherPageSubtitle => 'Create a multi-page PDF';

  @override
  String get saveDocument => 'Save document';

  @override
  String get savingDocument => 'Saving document…';

  @override
  String get recognizingText => 'Recognizing text…';

  @override
  String get cameraUnavailable => 'Could not open the camera. Check the permission.';

  @override
  String get cameraPermissionDenied => 'Docxan needs the camera to scan.';

  @override
  String get saveFailed => 'Could not save the document.';

  @override
  String get documentNotFound => 'Document not found';

  @override
  String get noPagesToSave => 'Add at least one page to save.';

  @override
  String get ocrUnavailable => 'Text was saved empty. The PDF is ready.';

  @override
  String get newFolder => 'New folder';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'No documents',
    );
    return '$_temp0';
  }

  @override
  String get open => 'Open';

  @override
  String get share => 'Share';

  @override
  String get export => 'Export';

  @override
  String get move => 'Move';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get ocrText => 'OCR text';

  @override
  String get syncStatus => 'Sync';

  @override
  String get storageStatus => 'Storage';

  @override
  String get syncOffline => 'Device only';

  @override
  String get syncPending => 'Pending upload';

  @override
  String get syncOk => 'Backup up to date';

  @override
  String get account => 'Account';

  @override
  String get security => 'Security';

  @override
  String get pin => '6-digit PIN';

  @override
  String get biometrics => 'Fingerprint or Face unlock';

  @override
  String get backup => 'Secure backup';

  @override
  String get backupSubtitle => 'Encrypted on the phone, stored on Cloudflare R2';

  @override
  String get deviceOnly => 'This device only';

  @override
  String get compression => 'Compression';

  @override
  String get compressionBalanced => 'Balanced';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get googleSignIn => 'Continue with Google';

  @override
  String get authBackendPending => 'Supabase keys are missing. Copy app/env.example.json to app/env.json and launch with --dart-define-from-file=env.json.';

  @override
  String get authCheckEmail => 'Check your email to verify the account before signing in.';

  @override
  String get authResetSent => 'If the email exists, we sent you a recovery link.';

  @override
  String get googlePending => 'The Google Web Client ID is missing in env.json, or SHA-1 / package in Google Cloud.';

  @override
  String get authInvalid => 'Invalid email or password.';

  @override
  String get passwordTooShort => 'The password must be at least 8 characters.';

  @override
  String get sendReset => 'Send link';

  @override
  String get lockTitle => 'Unlock Docxan';

  @override
  String get lockSubtitle => 'Enter your 6-digit PIN';

  @override
  String get searchHint => 'Name, folder, or OCR text';

  @override
  String get searchFilters => 'Filters';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get emptyFolders => 'No folders yet';

  @override
  String get emptyFoldersBody => 'Create a folder to organize what you scan.';

  @override
  String get emptyDocuments => 'No documents yet';

  @override
  String get emptyDocumentsBody => 'Scan a page to create the first one.';

  @override
  String get emptySearch => 'No results';

  @override
  String get emptySearchBody => 'When you have documents, they will show up here.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get demoBadge => 'Demo';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get trash => 'Trash';

  @override
  String get foldersSubtitle => 'Organize your documents easily. Open your folders and find what you need.';

  @override
  String get searchFolders => 'Search folders...';

  @override
  String get allFolders => 'All folders';

  @override
  String get myFiles => 'My files';

  @override
  String get favorites => 'Favorites';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get otherFolder => 'Other';

  @override
  String get pinSetupTitle => 'Create your PIN';

  @override
  String get pinSetupSubtitle => 'Choose 6 digits to protect Docxan on this device.';

  @override
  String get pinConfirmTitle => 'Repeat the PIN';

  @override
  String get pinConfirmSubtitle => 'Enter the same PIN again to confirm it.';

  @override
  String get pinMismatch => 'PINs do not match. Try again.';

  @override
  String get pinWrong => 'Incorrect PIN';

  @override
  String get pinCurrentTitle => 'Current PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get pinChanged => 'PIN updated';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get ocrSaved => 'OCR text saved';

  @override
  String get exportPdf => 'PDF';

  @override
  String get exportJpg => 'JPG';

  @override
  String get exportPng => 'PNG';

  @override
  String get exportWord => 'Word';

  @override
  String get download => 'Download';

  @override
  String get syncComingSoon => 'Sync will be available later.';

  @override
  String get syncAction => 'Sync';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get usedStorage => 'Used by Docxan';

  @override
  String get deviceStorage => 'Device storage';

  @override
  String storageUsedOf(String used, String total) {
    return '$used of $total';
  }

  @override
  String get cleanCache => 'Clear scan cache';

  @override
  String get cacheCleaned => 'Cache cleared';

  @override
  String get deleteLocalDocuments => 'Delete local documents';

  @override
  String get documentsDeleted => 'Local documents deleted';

  @override
  String get documentName => 'Document name';

  @override
  String get confirmDelete => 'Delete?';

  @override
  String get confirmDeleteFolder => 'The folder is removed and its documents move to My files.';

  @override
  String get confirmDeleteDocument => 'The document will go to the trash for 30 days.';

  @override
  String get confirmDeleteAll => 'All local documents will be permanently deleted.';

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get emptyCollection => 'No documents here';

  @override
  String get favorite => 'Favorite';

  @override
  String get unfavorite => 'Remove from favorites';

  @override
  String get moveToFolder => 'Move to folder';

  @override
  String get noFolder => 'My files';

  @override
  String get confirm => 'Confirm';

  @override
  String get profile => 'Profile';

  @override
  String get filterOcr => 'With OCR text';

  @override
  String get unlockWithBiometrics => 'Unlock with fingerprint or Face unlock';

  @override
  String get biometricsUnavailable => 'Biometrics are not available on this device.';

  @override
  String get legal => 'Legal';

  @override
  String get createFolderHint => 'For example, Invoices';

  @override
  String get unknownStorage => 'Unknown';

  @override
  String get scanTipLighting => 'Good lighting';

  @override
  String get scanTipFrame => 'Keep the document inside the frame';

  @override
  String get scanTipShadows => 'Avoid shadows on the paper';

  @override
  String get scanTipParallel => 'Keep the phone parallel to the document';

  @override
  String get scanTipBackground => 'Use a plain background';

  @override
  String get documentDetected => 'Document detected';

  @override
  String get syncNeedAccount => 'Create an account to sync.';

  @override
  String get syncNotConfigured => 'Add the Supabase or R2 keys in env.json.';

  @override
  String get syncComplete => 'Sync complete.';

  @override
  String get syncFailedMessage => 'Could not complete the sync.';

  @override
  String get syncNothingPending => 'Nothing pending.';

  @override
  String get syncInProgress => 'Syncing…';

  @override
  String get restoreComplete => 'Restore complete.';

  @override
  String get restoreFailed => 'Could not restore the backup.';

  @override
  String get syncUploading => 'Uploading';

  @override
  String get syncFailed => 'Sync error';

  @override
  String get relativeNow => 'Now';

  @override
  String relativeMinutes(int count) {
    return '$count min ago';
  }

  @override
  String relativeHours(int count) {
    return '$count h ago';
  }

  @override
  String get relativeYesterday => 'Yesterday';

  @override
  String relativeDays(int count) {
    return '$count d ago';
  }

}
