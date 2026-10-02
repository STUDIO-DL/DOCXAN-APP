// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Docxan';

  @override
  String get splashTagline => 'Des documents nets, sur votre téléphone.';

  @override
  String get onboardingTitle => 'Transformez le papier en documents numériques';

  @override
  String get onboardingBody =>
      'Scannez, améliorez et organisez depuis le téléphone. L’OCR et l’enregistrement fonctionnent sans Internet. Vos fichiers restent sur l’appareil, sauf si vous activez une sauvegarde chiffrée.';

  @override
  String get onboardingPrivacy =>
      'La confidentialité d’abord : rien n’est envoyé en clair. Si vous oubliez le code PIN, une sauvegarde de bout en bout ne peut pas être récupérée.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d’utilisation';

  @override
  String get getStarted => 'Commencer';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get continueAsGuest => 'Explorer sans compte';

  @override
  String get guestBanner =>
      'Vous êtes en mode invité. Créez un compte pour synchroniser et sauvegarder.';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get searchDocuments => 'Rechercher des documents...';

  @override
  String get searchTitle => 'Rechercher';

  @override
  String get homeSubtitle =>
      'Vos documents, toujours avec vous. Scannez, organisez et ouvrez-les quand vous en avez besoin.';

  @override
  String get viewAll => 'Tout voir';

  @override
  String get recentDocuments => 'Documents récents';

  @override
  String get recentFolders => 'Dossiers récents';

  @override
  String storageUsed(String used, String total) {
    return '$used sur $total';
  }

  @override
  String get addNewFolder => 'Ajouter un nouveau dossier';

  @override
  String get folderName => 'Nom du dossier';

  @override
  String get folderNameHint => 'ex. Personnel';

  @override
  String get createFolder => 'Créer';

  @override
  String get cancel => 'Annuler';

  @override
  String get folderNameEmpty => 'Saisissez un nom.';

  @override
  String get folderExists => 'Un dossier avec ce nom existe déjà.';

  @override
  String get fileType => 'Type de fichier';

  @override
  String get tags => 'Étiquettes';

  @override
  String get date => 'Date';

  @override
  String get urgent => 'Urgent';

  @override
  String get pending => 'En attente';

  @override
  String get today => 'Aujourd’hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get lastMonth => 'Mois dernier';

  @override
  String get accountAndProfile => 'Compte et profil';

  @override
  String get storagePlan => 'Forfait de stockage';

  @override
  String get personalData => 'Données personnelles';

  @override
  String get documentsSection => 'Documents';

  @override
  String get ocrLanguage => 'Langues OCR';

  @override
  String get defaultFormat => 'Formats par défaut';

  @override
  String get application => 'Application';

  @override
  String get securityAndPrivacy => 'Sécurité et confidentialité';

  @override
  String get notifications => 'Notifications';

  @override
  String get themeAndAppearance => 'Thème (sombre/clair)';

  @override
  String get totalStorage => 'Stockage total';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get recents => 'Récents';

  @override
  String get folders => 'Dossiers';

  @override
  String get scan => 'Scanner';

  @override
  String get settings => 'Réglages';

  @override
  String get home => 'Accueil';

  @override
  String get searchTab => 'Rechercher';

  @override
  String get scanCta => 'Scanner';

  @override
  String get scanPlaceholderTitle => 'Pointez vers le document';

  @override
  String get scanPlaceholderBody =>
      'La caméra, le recadrage et l’OCR se connectent à la semaine 2. Ce visuel marque le flux de capture.';

  @override
  String get scanDocument => 'Scanner un document';

  @override
  String get editDocument => 'Modifier le document';

  @override
  String get placeDocumentInFrame => 'Placez le document dans le cadre.';

  @override
  String get flash => 'Flash';

  @override
  String get gallery => 'Galerie';

  @override
  String get auto => 'Auto';

  @override
  String get manual => 'Manuel';

  @override
  String get autoDetectionSoon =>
      'La détection automatique sera disponible plus tard. Utilisez Manuel pour recadrer.';

  @override
  String get crop => 'Recadrer';

  @override
  String get rotate => 'Pivoter';

  @override
  String get brightness => 'Luminosité';

  @override
  String get contrast => 'Contraste';

  @override
  String get filters => 'Filtres';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterDocument => 'Document';

  @override
  String get filterBw => 'Noir et blanc';

  @override
  String get filterColor => 'Couleur';

  @override
  String get addAnotherPage => 'Ajouter une autre page';

  @override
  String get addAnotherPageSubtitle => 'Créer un PDF de plusieurs pages';

  @override
  String get saveDocument => 'Enregistrer le document';

  @override
  String get savingDocument => 'Enregistrement du document…';

  @override
  String get recognizingText => 'Reconnaissance du texte…';

  @override
  String get cameraUnavailable =>
      'Impossible d’ouvrir la caméra. Vérifiez l’autorisation.';

  @override
  String get cameraPermissionDenied =>
      'Docxan a besoin de la caméra pour scanner.';

  @override
  String get saveFailed => 'Impossible d’enregistrer le document.';

  @override
  String get documentNotFound => 'Document introuvable';

  @override
  String get noPagesToSave => 'Ajoutez au moins une page pour enregistrer.';

  @override
  String get ocrUnavailable =>
      'Le texte a été enregistré vide. Le PDF est prêt.';

  @override
  String get newFolder => 'Nouveau dossier';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'Aucun document',
    );
    return '$_temp0';
  }

  @override
  String get open => 'Ouvrir';

  @override
  String get share => 'Partager';

  @override
  String get export => 'Exporter';

  @override
  String get move => 'Déplacer';

  @override
  String get rename => 'Renommer';

  @override
  String get delete => 'Supprimer';

  @override
  String get ocrText => 'Texte OCR';

  @override
  String get syncStatus => 'Synchronisation';

  @override
  String get storageStatus => 'Stockage';

  @override
  String get syncOffline => 'Appareil uniquement';

  @override
  String get syncPending => 'En attente d’envoi';

  @override
  String get syncOk => 'Sauvegarde à jour';

  @override
  String get account => 'Compte';

  @override
  String get security => 'Sécurité';

  @override
  String get pin => 'Code PIN à 6 chiffres';

  @override
  String get biometrics => 'Empreinte ou déverrouillage facial';

  @override
  String get backup => 'Sauvegarde sécurisée';

  @override
  String get backupSubtitle =>
      'Chiffrée sur le téléphone, stockée sur Cloudflare R2';

  @override
  String get deviceOnly => 'Cet appareil uniquement';

  @override
  String get compression => 'Compression';

  @override
  String get compressionBalanced => 'Équilibrée';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get googleSignIn => 'Continuer avec Google';

  @override
  String get authBackendPending =>
      'Les clés Supabase manquent. Copiez app/env.example.json vers app/env.json et lancez avec --dart-define-from-file=env.json.';

  @override
  String get authCheckEmail =>
      'Vérifiez votre e-mail pour confirmer le compte avant de vous connecter.';

  @override
  String get authResetSent =>
      'Si l’e-mail existe, nous vous avons envoyé le lien de récupération.';

  @override
  String get googlePending =>
      'L’ID client Web Google manque dans env.json, ou le SHA-1 / package dans Google Cloud.';

  @override
  String get authInvalid => 'E-mail ou mot de passe non valides.';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get sendReset => 'Envoyer le lien';

  @override
  String get lockTitle => 'Déverrouiller Docxan';

  @override
  String get lockSubtitle => 'Saisissez votre code PIN à 6 chiffres';

  @override
  String get searchHint => 'Nom, dossier ou texte OCR';

  @override
  String get searchFilters => 'Filtres';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String get emptyFolders => 'Pas encore de dossiers';

  @override
  String get emptyFoldersBody => 'Créez un dossier pour classer vos scans.';

  @override
  String get emptyDocuments => 'Pas encore de documents';

  @override
  String get emptyDocumentsBody => 'Scannez une page pour créer le premier.';

  @override
  String get emptySearch => 'Aucun résultat';

  @override
  String get emptySearchBody =>
      'Lorsque vous aurez des documents, ils apparaîtront ici.';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get demoBadge => 'Démo';

  @override
  String get restoreBackup => 'Restaurer la sauvegarde';

  @override
  String get trash => 'Corbeille';

  @override
  String get foldersSubtitle =>
      'Organisez vos documents facilement. Ouvrez vos dossiers et trouvez ce dont vous avez besoin.';

  @override
  String get searchFolders => 'Rechercher des dossiers...';

  @override
  String get allFolders => 'Tous les dossiers';

  @override
  String get myFiles => 'Mes fichiers';

  @override
  String get favorites => 'Favoris';

  @override
  String get quickAccess => 'Accès rapides';

  @override
  String get otherFolder => 'Autres';

  @override
  String get pinSetupTitle => 'Créez votre code PIN';

  @override
  String get pinSetupSubtitle =>
      'Choisissez 6 chiffres pour protéger Docxan sur cet appareil.';

  @override
  String get pinConfirmTitle => 'Répétez le code PIN';

  @override
  String get pinConfirmSubtitle =>
      'Saisissez à nouveau le même code PIN pour le confirmer.';

  @override
  String get pinMismatch => 'Les codes PIN ne correspondent pas. Réessayez.';

  @override
  String get pinWrong => 'Code PIN incorrect';

  @override
  String get pinCurrentTitle => 'Code PIN actuel';

  @override
  String get changePin => 'Changer le code PIN';

  @override
  String get pinChanged => 'Code PIN mis à jour';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get ocrSaved => 'Texte OCR enregistré';

  @override
  String get exportPdf => 'PDF';

  @override
  String get exportJpg => 'JPG';

  @override
  String get exportPng => 'PNG';

  @override
  String get exportWord => 'Word';

  @override
  String get download => 'Télécharger';

  @override
  String get syncComingSoon => 'La synchronisation sera disponible plus tard.';

  @override
  String get syncAction => 'Synchroniser';

  @override
  String get language => 'Langue';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get lightTheme => 'Clair';

  @override
  String get usedStorage => 'Utilisé par Docxan';

  @override
  String get deviceStorage => 'Stockage de l’appareil';

  @override
  String storageUsedOf(String used, String total) {
    return '$used sur $total';
  }

  @override
  String get cleanCache => 'Vider le cache de scan';

  @override
  String get cacheCleaned => 'Cache vidé';

  @override
  String get deleteLocalDocuments => 'Supprimer les documents locaux';

  @override
  String get documentsDeleted => 'Documents locaux supprimés';

  @override
  String get documentName => 'Nom du document';

  @override
  String get confirmDelete => 'Supprimer ?';

  @override
  String get confirmDeleteFolder =>
      'Le dossier est supprimé et ses documents vont dans Mes fichiers.';

  @override
  String get confirmDeleteDocument =>
      'Le document ira à la corbeille pendant 30 jours.';

  @override
  String get confirmDeleteAll =>
      'Tous les documents locaux seront définitivement supprimés.';

  @override
  String get restore => 'Restaurer';

  @override
  String get deleteForever => 'Supprimer définitivement';

  @override
  String get emptyCollection => 'Aucun document ici';

  @override
  String get favorite => 'Favori';

  @override
  String get unfavorite => 'Retirer des favoris';

  @override
  String get moveToFolder => 'Déplacer vers un dossier';

  @override
  String get noFolder => 'Mes fichiers';

  @override
  String get confirm => 'Confirmer';

  @override
  String get profile => 'Profil';

  @override
  String get filterOcr => 'Avec texte OCR';

  @override
  String get unlockWithBiometrics =>
      'Déverrouiller avec l’empreinte ou le déverrouillage facial';

  @override
  String get biometricsUnavailable =>
      'La biométrie n’est pas disponible sur cet appareil.';

  @override
  String get legal => 'Mentions légales';

  @override
  String get createFolderHint => 'Par exemple, Factures';

  @override
  String get unknownStorage => 'Inconnu';

  @override
  String get scanTipLighting => 'Bon éclairage';

  @override
  String get scanTipFrame => 'Gardez le document dans le cadre';

  @override
  String get scanTipShadows => 'Évitez les ombres sur le papier';

  @override
  String get scanTipParallel => 'Téléphone parallèle au document';

  @override
  String get scanTipBackground => 'Utilisez un fond uni';

  @override
  String get documentDetected => 'Document détecté';

  @override
  String get syncNeedAccount => 'Créez un compte pour synchroniser.';

  @override
  String get syncNotConfigured =>
      'Ajoutez les clés Supabase ou R2 dans env.json.';

  @override
  String get syncComplete => 'Synchronisation terminée.';

  @override
  String get syncFailedMessage => 'Impossible de terminer la synchronisation.';

  @override
  String get syncNothingPending => 'Rien en attente.';

  @override
  String get syncInProgress => 'Synchronisation…';

  @override
  String get restoreComplete => 'Restauration terminée.';

  @override
  String get restoreFailed => 'Impossible de restaurer la sauvegarde.';

  @override
  String get syncUploading => 'Envoi';

  @override
  String get syncFailed => 'Erreur de sync';

  @override
  String get relativeNow => 'Maintenant';

  @override
  String relativeMinutes(int count) {
    return 'Il y a $count min';
  }

  @override
  String relativeHours(int count) {
    return 'Il y a $count h';
  }

  @override
  String get relativeYesterday => 'Hier';

  @override
  String relativeDays(int count) {
    return 'Il y a $count j';
  }

  @override
  String documentNamed(String date) {
    return 'Document $date';
  }

  @override
  String get retakePage => 'Reprendre';

  @override
  String get compressionSmall => 'Petit';

  @override
  String get compressionHigh => 'Haute qualité';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get folderPersonal => 'Personnel';

  @override
  String get folderUniversity => 'Université';

  @override
  String get folderWork => 'Travail';
}
