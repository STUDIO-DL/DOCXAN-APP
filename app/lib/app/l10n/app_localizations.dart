import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Docxan'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In es, this message translates to:
  /// **'Documentos limpios, en tu móvil.'**
  String get splashTagline;

  /// No description provided for @onboardingTitle.
  ///
  /// In es, this message translates to:
  /// **'Convierte papeles en documentos digitales'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In es, this message translates to:
  /// **'Escanea, mejora y organiza desde el teléfono. El OCR y el guardado funcionan sin Internet. Tus archivos se quedan en el dispositivo salvo que actives un backup cifrado.'**
  String get onboardingBody;

  /// No description provided for @onboardingPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad primero: nada se sube en claro. Si olvidas el PIN, un backup de extremo a extremo no se puede recuperar.'**
  String get onboardingPrivacy;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get termsOfUse;

  /// No description provided for @getStarted.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get getStarted;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @continueAsGuest.
  ///
  /// In es, this message translates to:
  /// **'Explorar sin cuenta'**
  String get continueAsGuest;

  /// No description provided for @guestBanner.
  ///
  /// In es, this message translates to:
  /// **'Estás en modo invitado. Crea una cuenta para sincronizar y hacer backup.'**
  String get guestBanner;

  /// No description provided for @goodMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos días'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get goodEvening;

  /// No description provided for @searchDocuments.
  ///
  /// In es, this message translates to:
  /// **'Buscar documentos...'**
  String get searchDocuments;

  /// No description provided for @searchTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus documentos, siempre contigo. Escanea, organiza y accede cuando lo necesites.'**
  String get homeSubtitle;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get viewAll;

  /// No description provided for @recentDocuments.
  ///
  /// In es, this message translates to:
  /// **'Documentos recientes'**
  String get recentDocuments;

  /// No description provided for @recentFolders.
  ///
  /// In es, this message translates to:
  /// **'Carpetas recientes'**
  String get recentFolders;

  /// No description provided for @storageUsed.
  ///
  /// In es, this message translates to:
  /// **'{used} de {total}'**
  String storageUsed(String used, String total);

  /// No description provided for @addNewFolder.
  ///
  /// In es, this message translates to:
  /// **'Añadir nueva carpeta'**
  String get addNewFolder;

  /// No description provided for @folderName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la carpeta'**
  String get folderName;

  /// No description provided for @folderNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Personal'**
  String get folderNameHint;

  /// No description provided for @createFolder.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get createFolder;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @folderNameEmpty.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre.'**
  String get folderNameEmpty;

  /// No description provided for @folderExists.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una carpeta con ese nombre.'**
  String get folderExists;

  /// No description provided for @fileType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de archivo'**
  String get fileType;

  /// No description provided for @tags.
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get tags;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @urgent.
  ///
  /// In es, this message translates to:
  /// **'Urgente'**
  String get urgent;

  /// No description provided for @pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @lastMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes pasado'**
  String get lastMonth;

  /// No description provided for @accountAndProfile.
  ///
  /// In es, this message translates to:
  /// **'Cuenta y perfil'**
  String get accountAndProfile;

  /// No description provided for @storagePlan.
  ///
  /// In es, this message translates to:
  /// **'Plan de almacenamiento'**
  String get storagePlan;

  /// No description provided for @personalData.
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get personalData;

  /// No description provided for @documentsSection.
  ///
  /// In es, this message translates to:
  /// **'Documentos'**
  String get documentsSection;

  /// No description provided for @ocrLanguage.
  ///
  /// In es, this message translates to:
  /// **'OCR idiomas'**
  String get ocrLanguage;

  /// No description provided for @defaultFormat.
  ///
  /// In es, this message translates to:
  /// **'Formatos predeterminados'**
  String get defaultFormat;

  /// No description provided for @application.
  ///
  /// In es, this message translates to:
  /// **'Aplicación'**
  String get application;

  /// No description provided for @securityAndPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Seguridad y privacidad'**
  String get securityAndPrivacy;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @themeAndAppearance.
  ///
  /// In es, this message translates to:
  /// **'Tema (oscuro/claro)'**
  String get themeAndAppearance;

  /// No description provided for @totalStorage.
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento total'**
  String get totalStorage;

  /// No description provided for @viewDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get viewDetails;

  /// No description provided for @recents.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get recents;

  /// No description provided for @folders.
  ///
  /// In es, this message translates to:
  /// **'Carpetas'**
  String get folders;

  /// No description provided for @scan.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get scan;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @scanCta.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get scanCta;

  /// No description provided for @scanPlaceholderTitle.
  ///
  /// In es, this message translates to:
  /// **'Apunta al documento'**
  String get scanPlaceholderTitle;

  /// No description provided for @scanPlaceholderBody.
  ///
  /// In es, this message translates to:
  /// **'La cámara, el recorte y el OCR se conectan en la semana 2. Este visor marca el flujo de captura.'**
  String get scanPlaceholderBody;

  /// No description provided for @newFolder.
  ///
  /// In es, this message translates to:
  /// **'Nueva carpeta'**
  String get newFolder;

  /// No description provided for @documentsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin documentos} one{1 documento} other{{count} documentos}}'**
  String documentsCount(int count);

  /// No description provided for @open.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get open;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @export.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get export;

  /// No description provided for @move.
  ///
  /// In es, this message translates to:
  /// **'Mover'**
  String get move;

  /// No description provided for @rename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @ocrText.
  ///
  /// In es, this message translates to:
  /// **'Texto OCR'**
  String get ocrText;

  /// No description provided for @syncStatus.
  ///
  /// In es, this message translates to:
  /// **'Sincronización'**
  String get syncStatus;

  /// No description provided for @storageStatus.
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento'**
  String get storageStatus;

  /// No description provided for @syncOffline.
  ///
  /// In es, this message translates to:
  /// **'Solo dispositivo'**
  String get syncOffline;

  /// No description provided for @syncPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de subir'**
  String get syncPending;

  /// No description provided for @syncOk.
  ///
  /// In es, this message translates to:
  /// **'Copia al día'**
  String get syncOk;

  /// No description provided for @account.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get account;

  /// No description provided for @security.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// No description provided for @pin.
  ///
  /// In es, this message translates to:
  /// **'PIN de 6 dígitos'**
  String get pin;

  /// No description provided for @biometrics.
  ///
  /// In es, this message translates to:
  /// **'Huella o Face unlock'**
  String get biometrics;

  /// No description provided for @backup.
  ///
  /// In es, this message translates to:
  /// **'Backup seguro'**
  String get backup;

  /// No description provided for @backupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cifrado en el móvil, guardado en Cloudflare R2'**
  String get backupSubtitle;

  /// No description provided for @deviceOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo este dispositivo'**
  String get deviceOnly;

  /// No description provided for @compression.
  ///
  /// In es, this message translates to:
  /// **'Compresión'**
  String get compression;

  /// No description provided for @compressionBalanced.
  ///
  /// In es, this message translates to:
  /// **'Equilibrada'**
  String get compressionBalanced;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste la contraseña?'**
  String get forgotPassword;

  /// No description provided for @googleSignIn.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get googleSignIn;

  /// No description provided for @authBackendPending.
  ///
  /// In es, this message translates to:
  /// **'Faltan las claves de Supabase. Copia app/env.example.json a app/env.json y lanza con --dart-define-from-file=env.json.'**
  String get authBackendPending;

  /// No description provided for @authCheckEmail.
  ///
  /// In es, this message translates to:
  /// **'Revisa el correo para verificar la cuenta antes de entrar.'**
  String get authCheckEmail;

  /// No description provided for @authResetSent.
  ///
  /// In es, this message translates to:
  /// **'Si el correo existe, te hemos enviado el enlace de recuperación.'**
  String get authResetSent;

  /// No description provided for @googlePending.
  ///
  /// In es, this message translates to:
  /// **'Falta el Client ID Web de Google en env.json, o SHA-1 / package en Google Cloud.'**
  String get googlePending;

  /// No description provided for @authInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña no válidos.'**
  String get authInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres.'**
  String get passwordTooShort;

  /// No description provided for @sendReset.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get sendReset;

  /// No description provided for @lockTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear Docxan'**
  String get lockTitle;

  /// No description provided for @lockSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu PIN de 6 dígitos'**
  String get lockSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre, carpeta o texto OCR'**
  String get searchHint;

  /// No description provided for @searchFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get searchFilters;

  /// No description provided for @recentSearches.
  ///
  /// In es, this message translates to:
  /// **'Búsquedas recientes'**
  String get recentSearches;

  /// No description provided for @emptyFolders.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay carpetas'**
  String get emptyFolders;

  /// No description provided for @emptyFoldersBody.
  ///
  /// In es, this message translates to:
  /// **'Crea una carpeta para ordenar lo que escanees.'**
  String get emptyFoldersBody;

  /// No description provided for @emptyDocuments.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay documentos'**
  String get emptyDocuments;

  /// No description provided for @emptyDocumentsBody.
  ///
  /// In es, this message translates to:
  /// **'Escanea un papel para crear el primero.'**
  String get emptyDocumentsBody;

  /// No description provided for @emptySearch.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get emptySearch;

  /// No description provided for @emptySearchBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando tengas documentos, aparecerán aquí.'**
  String get emptySearchBody;

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoon;

  /// No description provided for @demoBadge.
  ///
  /// In es, this message translates to:
  /// **'Demo'**
  String get demoBadge;

  /// No description provided for @restoreBackup.
  ///
  /// In es, this message translates to:
  /// **'Restaurar backup'**
  String get restoreBackup;

  /// No description provided for @trash.
  ///
  /// In es, this message translates to:
  /// **'Papelera'**
  String get trash;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
