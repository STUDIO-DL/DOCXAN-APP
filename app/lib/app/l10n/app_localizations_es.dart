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
  String get onboardingBody => 'Escanea, mejora y organiza desde el teléfono. El OCR y el guardado funcionan sin Internet. Tus archivos se quedan en el dispositivo salvo que actives un backup cifrado.';

  @override
  String get onboardingPrivacy => 'Privacidad primero: nada se sube en claro. Si olvidas el PIN, un backup de extremo a extremo no se puede recuperar.';

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
  String get guestBanner => 'Estás en modo invitado. Crea una cuenta para sincronizar y hacer backup.';

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
  String get homeSubtitle => 'Tus documentos, siempre contigo. Escanea, organiza y accede cuando lo necesites.';

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
  String get searchTab => 'Buscar';

  @override
  String get scanCta => 'Escanear';

  @override
  String get scanPlaceholderTitle => 'Apunta al documento';

  @override
  String get scanPlaceholderBody => 'La cámara, el recorte y el OCR se conectan en la semana 2. Este visor marca el flujo de captura.';

  @override
  String get scanDocument => 'Escanear documento';

  @override
  String get editDocument => 'Editar documento';

  @override
  String get placeDocumentInFrame => 'Coloca el documento dentro del marco.';

  @override
  String get flash => 'Flash';

  @override
  String get gallery => 'Galería';

  @override
  String get auto => 'Auto';

  @override
  String get manual => 'Manual';

  @override
  String get autoDetectionSoon => 'La detección automática estará disponible más adelante. Usa Manual para recortar.';

  @override
  String get crop => 'Recortar';

  @override
  String get rotate => 'Rotar';

  @override
  String get brightness => 'Brillo';

  @override
  String get contrast => 'Contraste';

  @override
  String get filters => 'Filtros';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterDocument => 'Documento';

  @override
  String get filterBw => 'Blanco y negro';

  @override
  String get filterColor => 'Color';

  @override
  String get addAnotherPage => 'Añadir otra página';

  @override
  String get addAnotherPageSubtitle => 'Crear un PDF de varias páginas';

  @override
  String get saveDocument => 'Guardar documento';

  @override
  String get savingDocument => 'Guardando documento…';

  @override
  String get recognizingText => 'Reconociendo texto…';

  @override
  String get cameraUnavailable => 'No se pudo abrir la cámara. Comprueba el permiso.';

  @override
  String get cameraPermissionDenied => 'Docxan necesita la cámara para escanear.';

  @override
  String get saveFailed => 'No se pudo guardar el documento.';

  @override
  String get documentNotFound => 'Documento no encontrado';

  @override
  String get noPagesToSave => 'Añade al menos una página para guardar.';

  @override
  String get ocrUnavailable => 'El texto se guardó vacío. El PDF está listo.';

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
  String get authBackendPending => 'Faltan las claves de Supabase. Copia app/env.example.json a app/env.json y lanza con --dart-define-from-file=env.json.';

  @override
  String get authCheckEmail => 'Revisa el correo para verificar la cuenta antes de entrar.';

  @override
  String get authResetSent => 'Si el correo existe, te hemos enviado el enlace de recuperación.';

  @override
  String get googlePending => 'Falta el Client ID Web de Google en env.json, o SHA-1 / package en Google Cloud.';

  @override
  String get authInvalid => 'Correo o contraseña no válidos.';

  @override
  String get passwordTooShort => 'La contraseña debe tener al menos 8 caracteres.';

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
  String get emptyFoldersBody => 'Crea una carpeta para ordenar lo que escanees.';

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

  @override
  String get foldersSubtitle => 'Organiza tus documentos fácilmente. Accede a tus carpetas y encuentra lo que necesitas.';

  @override
  String get searchFolders => 'Buscar carpetas...';

  @override
  String get allFolders => 'Todas las carpetas';

  @override
  String get myFiles => 'Mis archivos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get quickAccess => 'Accesos rápidos';

  @override
  String get otherFolder => 'Otros';

  @override
  String get pinSetupTitle => 'Crea tu PIN';

  @override
  String get pinSetupSubtitle => 'Elige 6 dígitos para proteger Docxan en este dispositivo.';

  @override
  String get pinConfirmTitle => 'Repite el PIN';

  @override
  String get pinConfirmSubtitle => 'Vuelve a introducir el mismo PIN para confirmarlo.';

  @override
  String get pinMismatch => 'Los PIN no coinciden. Inténtalo de nuevo.';

  @override
  String get pinWrong => 'PIN incorrecto';

  @override
  String get pinCurrentTitle => 'PIN actual';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get pinChanged => 'PIN actualizado';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get ocrSaved => 'Texto OCR guardado';

  @override
  String get exportPdf => 'PDF';

  @override
  String get exportJpg => 'JPG';

  @override
  String get exportPng => 'PNG';

  @override
  String get exportWord => 'Word';

  @override
  String get download => 'Descargar';

  @override
  String get syncComingSoon => 'La sincronización estará disponible más adelante.';

  @override
  String get syncAction => 'Sincronizar';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get usedStorage => 'Usado por Docxan';

  @override
  String get deviceStorage => 'Almacenamiento del dispositivo';

  @override
  String storageUsedOf(String used, String total) {
    return '$used de $total';
  }

  @override
  String get cleanCache => 'Vaciar caché de escaneo';

  @override
  String get cacheCleaned => 'Caché vaciada';

  @override
  String get deleteLocalDocuments => 'Eliminar documentos locales';

  @override
  String get documentsDeleted => 'Documentos locales eliminados';

  @override
  String get documentName => 'Nombre del documento';

  @override
  String get confirmDelete => '¿Eliminar?';

  @override
  String get confirmDeleteFolder => 'La carpeta se elimina y sus documentos pasan a Mis archivos.';

  @override
  String get confirmDeleteDocument => 'El documento irá a la papelera durante 30 días.';

  @override
  String get confirmDeleteAll => 'Se eliminarán de forma permanente todos los documentos locales.';

  @override
  String get restore => 'Restaurar';

  @override
  String get deleteForever => 'Eliminar definitivamente';

  @override
  String get emptyCollection => 'No hay documentos aquí';

  @override
  String get favorite => 'Favorito';

  @override
  String get unfavorite => 'Quitar de favoritos';

  @override
  String get moveToFolder => 'Mover a carpeta';

  @override
  String get noFolder => 'Mis archivos';

  @override
  String get confirm => 'Confirmar';

  @override
  String get profile => 'Perfil';

  @override
  String get filterOcr => 'Con texto OCR';

  @override
  String get unlockWithBiometrics => 'Desbloquear con huella o Face unlock';

  @override
  String get biometricsUnavailable => 'La biometría no está disponible en este dispositivo.';

  @override
  String get legal => 'Legal';

  @override
  String get createFolderHint => 'Por ejemplo, Facturas';

  @override
  String get unknownStorage => 'Desconocido';

  @override
  String get scanTipLighting => 'Buena iluminación';

  @override
  String get scanTipFrame => 'Mantén el documento dentro del marco';

  @override
  String get scanTipShadows => 'Evita sombras sobre el papel';

  @override
  String get scanTipParallel => 'Teléfono paralelo al documento';

  @override
  String get scanTipBackground => 'Usa un fondo liso';

  @override
  String get documentDetected => 'Documento detectado';

  @override
  String get syncNeedAccount => 'Crea una cuenta para sincronizar.';

  @override
  String get syncNotConfigured => 'Añade las claves de Supabase o R2 en env.json.';

  @override
  String get syncComplete => 'Sincronización lista.';

  @override
  String get syncFailedMessage => 'No se pudo completar la sincronización.';

  @override
  String get syncNothingPending => 'Nada pendiente.';

  @override
  String get syncInProgress => 'Sincronizando…';

  @override
  String get restoreComplete => 'Restauración lista.';

  @override
  String get restoreFailed => 'No se pudo restaurar el backup.';

  @override
  String get syncUploading => 'Subiendo';

  @override
  String get syncFailed => 'Error de sync';

  @override
  String get relativeNow => 'Ahora';

  @override
  String relativeMinutes(int count) {
    return 'Hace $count min';
  }

  @override
  String relativeHours(int count) {
    return 'Hace $count h';
  }

  @override
  String get relativeYesterday => 'Ayer';

  @override
  String relativeDays(int count) {
    return 'Hace $count d';
  }

}
