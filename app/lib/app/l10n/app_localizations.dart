import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

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

  /// No description provided for @searchTab.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchTab;

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

  /// No description provided for @scanDocument.
  ///
  /// In es, this message translates to:
  /// **'Escanear documento'**
  String get scanDocument;

  /// No description provided for @editDocument.
  ///
  /// In es, this message translates to:
  /// **'Editar documento'**
  String get editDocument;

  /// No description provided for @placeDocumentInFrame.
  ///
  /// In es, this message translates to:
  /// **'Coloca el documento dentro del marco.'**
  String get placeDocumentInFrame;

  /// No description provided for @flash.
  ///
  /// In es, this message translates to:
  /// **'Flash'**
  String get flash;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get gallery;

  /// No description provided for @auto.
  ///
  /// In es, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @manual.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @autoDetectionSoon.
  ///
  /// In es, this message translates to:
  /// **'La detección automática estará disponible más adelante. Usa Manual para recortar.'**
  String get autoDetectionSoon;

  /// No description provided for @crop.
  ///
  /// In es, this message translates to:
  /// **'Recortar'**
  String get crop;

  /// No description provided for @rotate.
  ///
  /// In es, this message translates to:
  /// **'Rotar'**
  String get rotate;

  /// No description provided for @brightness.
  ///
  /// In es, this message translates to:
  /// **'Brillo'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In es, this message translates to:
  /// **'Contraste'**
  String get contrast;

  /// No description provided for @filters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// No description provided for @filterOriginal.
  ///
  /// In es, this message translates to:
  /// **'Original'**
  String get filterOriginal;

  /// No description provided for @filterDocument.
  ///
  /// In es, this message translates to:
  /// **'Documento'**
  String get filterDocument;

  /// No description provided for @filterBw.
  ///
  /// In es, this message translates to:
  /// **'Blanco y negro'**
  String get filterBw;

  /// No description provided for @filterColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get filterColor;

  /// No description provided for @addAnotherPage.
  ///
  /// In es, this message translates to:
  /// **'Añadir otra página'**
  String get addAnotherPage;

  /// No description provided for @addAnotherPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crear un PDF de varias páginas'**
  String get addAnotherPageSubtitle;

  /// No description provided for @saveDocument.
  ///
  /// In es, this message translates to:
  /// **'Guardar documento'**
  String get saveDocument;

  /// No description provided for @savingDocument.
  ///
  /// In es, this message translates to:
  /// **'Guardando documento…'**
  String get savingDocument;

  /// No description provided for @recognizingText.
  ///
  /// In es, this message translates to:
  /// **'Reconociendo texto…'**
  String get recognizingText;

  /// No description provided for @cameraUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la cámara. Comprueba el permiso.'**
  String get cameraUnavailable;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Docxan necesita la cámara para escanear.'**
  String get cameraPermissionDenied;

  /// No description provided for @saveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el documento.'**
  String get saveFailed;

  /// No description provided for @documentNotFound.
  ///
  /// In es, this message translates to:
  /// **'Documento no encontrado'**
  String get documentNotFound;

  /// No description provided for @noPagesToSave.
  ///
  /// In es, this message translates to:
  /// **'Añade al menos una página para guardar.'**
  String get noPagesToSave;

  /// No description provided for @ocrUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El texto se guardó vacío. El PDF está listo.'**
  String get ocrUnavailable;

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

  /// No description provided for @foldersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza tus documentos fácilmente. Accede a tus carpetas y encuentra lo que necesitas.'**
  String get foldersSubtitle;

  /// No description provided for @searchFolders.
  ///
  /// In es, this message translates to:
  /// **'Buscar carpetas...'**
  String get searchFolders;

  /// No description provided for @allFolders.
  ///
  /// In es, this message translates to:
  /// **'Todas las carpetas'**
  String get allFolders;

  /// No description provided for @myFiles.
  ///
  /// In es, this message translates to:
  /// **'Mis archivos'**
  String get myFiles;

  /// No description provided for @favorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @quickAccess.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get quickAccess;

  /// No description provided for @otherFolder.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get otherFolder;

  /// No description provided for @pinSetupTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinSetupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige 6 dígitos para proteger Docxan en este dispositivo.'**
  String get pinSetupSubtitle;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Repite el PIN'**
  String get pinConfirmTitle;

  /// No description provided for @pinConfirmSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a introducir el mismo PIN para confirmarlo.'**
  String get pinConfirmSubtitle;

  /// No description provided for @pinMismatch.
  ///
  /// In es, this message translates to:
  /// **'Los PIN no coinciden. Inténtalo de nuevo.'**
  String get pinMismatch;

  /// No description provided for @pinWrong.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto'**
  String get pinWrong;

  /// No description provided for @pinCurrentTitle.
  ///
  /// In es, this message translates to:
  /// **'PIN actual'**
  String get pinCurrentTitle;

  /// No description provided for @changePin.
  ///
  /// In es, this message translates to:
  /// **'Cambiar PIN'**
  String get changePin;

  /// No description provided for @pinChanged.
  ///
  /// In es, this message translates to:
  /// **'PIN actualizado'**
  String get pinChanged;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

  /// No description provided for @ocrSaved.
  ///
  /// In es, this message translates to:
  /// **'Texto OCR guardado'**
  String get ocrSaved;

  /// No description provided for @exportPdf.
  ///
  /// In es, this message translates to:
  /// **'PDF'**
  String get exportPdf;

  /// No description provided for @exportJpg.
  ///
  /// In es, this message translates to:
  /// **'JPG'**
  String get exportJpg;

  /// No description provided for @exportPng.
  ///
  /// In es, this message translates to:
  /// **'PNG'**
  String get exportPng;

  /// No description provided for @exportWord.
  ///
  /// In es, this message translates to:
  /// **'Word'**
  String get exportWord;

  /// No description provided for @download.
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get download;

  /// No description provided for @syncComingSoon.
  ///
  /// In es, this message translates to:
  /// **'La sincronización estará disponible más adelante.'**
  String get syncComingSoon;

  /// No description provided for @syncAction.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar'**
  String get syncAction;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In es, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightTheme;

  /// No description provided for @usedStorage.
  ///
  /// In es, this message translates to:
  /// **'Usado por Docxan'**
  String get usedStorage;

  /// No description provided for @deviceStorage.
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento del dispositivo'**
  String get deviceStorage;

  /// No description provided for @storageUsedOf.
  ///
  /// In es, this message translates to:
  /// **'{used} de {total}'**
  String storageUsedOf(String used, String total);

  /// No description provided for @cleanCache.
  ///
  /// In es, this message translates to:
  /// **'Vaciar caché de escaneo'**
  String get cleanCache;

  /// No description provided for @cacheCleaned.
  ///
  /// In es, this message translates to:
  /// **'Caché vaciada'**
  String get cacheCleaned;

  /// No description provided for @deleteLocalDocuments.
  ///
  /// In es, this message translates to:
  /// **'Eliminar documentos locales'**
  String get deleteLocalDocuments;

  /// No description provided for @documentsDeleted.
  ///
  /// In es, this message translates to:
  /// **'Documentos locales eliminados'**
  String get documentsDeleted;

  /// No description provided for @documentName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del documento'**
  String get documentName;

  /// No description provided for @confirmDelete.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteFolder.
  ///
  /// In es, this message translates to:
  /// **'La carpeta se elimina y sus documentos pasan a Mis archivos.'**
  String get confirmDeleteFolder;

  /// No description provided for @confirmDeleteDocument.
  ///
  /// In es, this message translates to:
  /// **'El documento irá a la papelera durante 30 días.'**
  String get confirmDeleteDocument;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán de forma permanente todos los documentos locales.'**
  String get confirmDeleteAll;

  /// No description provided for @restore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restore;

  /// No description provided for @deleteForever.
  ///
  /// In es, this message translates to:
  /// **'Eliminar definitivamente'**
  String get deleteForever;

  /// No description provided for @emptyCollection.
  ///
  /// In es, this message translates to:
  /// **'No hay documentos aquí'**
  String get emptyCollection;

  /// No description provided for @favorite.
  ///
  /// In es, this message translates to:
  /// **'Favorito'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get unfavorite;

  /// No description provided for @moveToFolder.
  ///
  /// In es, this message translates to:
  /// **'Mover a carpeta'**
  String get moveToFolder;

  /// No description provided for @noFolder.
  ///
  /// In es, this message translates to:
  /// **'Mis archivos'**
  String get noFolder;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @filterOcr.
  ///
  /// In es, this message translates to:
  /// **'Con texto OCR'**
  String get filterOcr;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con huella o Face unlock'**
  String get unlockWithBiometrics;

  /// No description provided for @biometricsUnavailable.
  ///
  /// In es, this message translates to:
  /// **'La biometría no está disponible en este dispositivo.'**
  String get biometricsUnavailable;

  /// No description provided for @legal.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @createFolderHint.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo, Facturas'**
  String get createFolderHint;

  /// No description provided for @unknownStorage.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknownStorage;

  /// No description provided for @scanTipLighting.
  ///
  /// In es, this message translates to:
  /// **'Buena iluminación'**
  String get scanTipLighting;

  /// No description provided for @scanTipFrame.
  ///
  /// In es, this message translates to:
  /// **'Mantén el documento dentro del marco'**
  String get scanTipFrame;

  /// No description provided for @scanTipShadows.
  ///
  /// In es, this message translates to:
  /// **'Evita sombras sobre el papel'**
  String get scanTipShadows;

  /// No description provided for @scanTipParallel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono paralelo al documento'**
  String get scanTipParallel;

  /// No description provided for @scanTipBackground.
  ///
  /// In es, this message translates to:
  /// **'Usa un fondo liso'**
  String get scanTipBackground;

  /// No description provided for @documentDetected.
  ///
  /// In es, this message translates to:
  /// **'Documento detectado'**
  String get documentDetected;

  /// No description provided for @syncNeedAccount.
  ///
  /// In es, this message translates to:
  /// **'Crea una cuenta para sincronizar.'**
  String get syncNeedAccount;

  /// No description provided for @syncNotConfigured.
  ///
  /// In es, this message translates to:
  /// **'Añade las claves de Supabase o R2 en env.json.'**
  String get syncNotConfigured;

  /// No description provided for @syncComplete.
  ///
  /// In es, this message translates to:
  /// **'Sincronización lista.'**
  String get syncComplete;

  /// No description provided for @syncFailedMessage.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la sincronización.'**
  String get syncFailedMessage;

  /// No description provided for @syncNothingPending.
  ///
  /// In es, this message translates to:
  /// **'Nada pendiente.'**
  String get syncNothingPending;

  /// No description provided for @syncInProgress.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando…'**
  String get syncInProgress;

  /// No description provided for @restoreComplete.
  ///
  /// In es, this message translates to:
  /// **'Restauración lista.'**
  String get restoreComplete;

  /// No description provided for @restoreFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo restaurar el backup.'**
  String get restoreFailed;

  /// No description provided for @syncUploading.
  ///
  /// In es, this message translates to:
  /// **'Subiendo'**
  String get syncUploading;

  /// No description provided for @syncFailed.
  ///
  /// In es, this message translates to:
  /// **'Error de sync'**
  String get syncFailed;

  /// No description provided for @relativeNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get relativeNow;

  /// No description provided for @relativeMinutes.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} min'**
  String relativeMinutes(int count);

  /// No description provided for @relativeHours.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} h'**
  String relativeHours(int count);

  /// No description provided for @relativeYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get relativeYesterday;

  /// No description provided for @relativeDays.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} d'**
  String relativeDays(int count);
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

