// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Docxan';

  @override
  String get splashTagline => 'Documentos limpios, en tu móvil.';

  @override
  String get onboardingTitle => 'Convierte papeles en documentos digitales';

  @override
  String get onboardingBody =>
      'Escanea, mejora y organiza desde el teléfono. El OCR y el guardado funcionan sin Internet. Tus archivos se quedan en el dispositivo salvo que actives un backup cifrado.';

  @override
  String get onboardingPrivacy =>
      'Privacidad primero: nada se sube en claro. Si olvidas el PIN, un backup de extremo a extremo no se puede recuperar.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get getStarted => 'Empezar';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get continueAsGuest => 'Explorar sin cuenta';

  @override
  String get guestBanner =>
      'Estás en modo invitado. Crea una cuenta para sincronizar y hacer backup.';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get searchDocuments => 'Buscar documentos...';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get homeSubtitle =>
      'Tus documentos, siempre contigo. Escanea, organiza y accede cuando lo necesites.';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get recentDocuments => 'Documentos recientes';

  @override
  String get recentFolders => 'Carpetas recientes';

  @override
  String storageUsed(String used, String total) {
    return '$used de $total';
  }

  @override
  String get addNewFolder => 'Añadir nueva carpeta';

  @override
  String get folderName => 'Nombre de la carpeta';

  @override
  String get folderNameHint => 'Ej. Personal';

  @override
  String get createFolder => 'Crear';

  @override
  String get cancel => 'Cancelar';

  @override
  String get folderNameEmpty => 'Escribe un nombre.';

  @override
  String get folderExists => 'Ya existe una carpeta con ese nombre.';

  @override
  String get fileType => 'Tipo de archivo';

  @override
  String get tags => 'Etiquetas';

  @override
  String get date => 'Fecha';

  @override
  String get urgent => 'Urgente';

  @override
  String get pending => 'Pendiente';

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastMonth => 'Mes pasado';

  @override
  String get accountAndProfile => 'Cuenta y perfil';

  @override
  String get storagePlan => 'Plan de almacenamiento';

  @override
  String get personalData => 'Datos personales';

  @override
  String get documentsSection => 'Documentos';

  @override
  String get ocrLanguage => 'OCR idiomas';

  @override
  String get defaultFormat => 'Formatos predeterminados';

  @override
  String get application => 'Aplicación';

  @override
  String get securityAndPrivacy => 'Seguridad y privacidad';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get themeAndAppearance => 'Tema (oscuro/claro)';

  @override
  String get totalStorage => 'Almacenamiento total';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get recents => 'Recientes';

  @override
  String get folders => 'Carpetas';

  @override
  String get scan => 'Escanear';

  @override
  String get settings => 'Ajustes';

  @override
  String get home => 'Inicio';

  @override
  String get scanCta => 'Escanear';

  @override
  String get scanPlaceholderTitle => 'Apunta al documento';

  @override
  String get scanPlaceholderBody =>
      'La cámara, el recorte y el OCR se conectan en la semana 2. Este visor marca el flujo de captura.';

  @override
  String get newFolder => 'Nueva carpeta';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos',
      one: '1 documento',
      zero: 'Sin documentos',
    );
    return '$_temp0';
  }

  @override
  String get open => 'Abrir';

  @override
  String get share => 'Compartir';

  @override
  String get export => 'Exportar';

  @override
  String get move => 'Mover';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get ocrText => 'Texto OCR';

  @override
  String get syncStatus => 'Sincronización';

  @override
  String get storageStatus => 'Almacenamiento';

  @override
  String get syncOffline => 'Solo dispositivo';

  @override
  String get syncPending => 'Pendiente de subir';

  @override
  String get syncOk => 'Copia al día';

  @override
  String get account => 'Cuenta';

  @override
  String get security => 'Seguridad';

  @override
  String get pin => 'PIN de 6 dígitos';

  @override
  String get biometrics => 'Huella o Face unlock';

  @override
  String get backup => 'Backup seguro';

  @override
  String get backupSubtitle => 'Cifrado en el móvil, guardado en Cloudflare R2';

  @override
  String get deviceOnly => 'Solo este dispositivo';

  @override
  String get compression => 'Compresión';

  @override
  String get compressionBalanced => 'Equilibrada';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get googleSignIn => 'Continuar con Google';

  @override
  String get authBackendPending =>
      'Faltan las claves de Supabase. Copia app/env.example.json a app/env.json y lanza con --dart-define-from-file=env.json.';

  @override
  String get authCheckEmail =>
      'Revisa el correo para verificar la cuenta antes de entrar.';

  @override
  String get authResetSent =>
      'Si el correo existe, te hemos enviado el enlace de recuperación.';

  @override
  String get googlePending =>
      'Falta el Client ID Web de Google en env.json, o SHA-1 / package en Google Cloud.';

  @override
  String get authInvalid => 'Correo o contraseña no válidos.';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get sendReset => 'Enviar enlace';

  @override
  String get lockTitle => 'Desbloquear Docxan';

  @override
  String get lockSubtitle => 'Introduce tu PIN de 6 dígitos';

  @override
  String get searchHint => 'Nombre, carpeta o texto OCR';

  @override
  String get searchFilters => 'Filtros';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String get emptyFolders => 'Aún no hay carpetas';

  @override
  String get emptyFoldersBody =>
      'Crea una carpeta para ordenar lo que escanees.';

  @override
  String get emptyDocuments => 'Aún no hay documentos';

  @override
  String get emptyDocumentsBody => 'Escanea un papel para crear el primero.';

  @override
  String get emptySearch => 'Sin resultados';

  @override
  String get emptySearchBody => 'Cuando tengas documentos, aparecerán aquí.';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get demoBadge => 'Demo';

  @override
  String get restoreBackup => 'Restaurar backup';

  @override
  String get trash => 'Papelera';
}
