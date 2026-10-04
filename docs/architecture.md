# Arquitectura Docxan

Cliente-servidor **offline-first**. Drift (local) es la fuente de verdad diaria. Supabase guarda metadatos no sensibles. Cloudflare R2 guarda **solo ciphertext**.

Credenciales de la app (solo `app/env.json`, nunca en el repo):

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GOOGLE_WEB_CLIENT_ID` (opcional, Google Sign-In aparcado)

Los tokens S3 de R2 viven en **Edge Function secrets**, no en el APK.

La sincronización es **manual** (botón Sincronizar). Estados: `local_only`, `pending_upload`, `uploading`, `synced`, `failed`.

## Capas

```
app/lib/app        composition root (router, theme, flavors)
app/lib/core       crypto, db, sync, session, design system
app/lib/features/* módulos verticales (data / domain / presentation)
```

Un feature no importa a otro. Contratos compartidos: `DocumentSummary`, `FolderSummary`, `Session`.

## Backup (R2)

1. La app pide a `backup-signed-url` (`action: backup_key`) su clave de servidor por usuario ("pepper", 32 bytes, `HMAC-SHA256(BACKUP_PEPPER_SECRET, user_id)`). Solo se cachea en memoria.
2. Cifra el blob con AES-256-GCM. Formato **DXN2**: `DXN2 | salt(16) | nonce(12) | ciphertext | mac(16)`; clave = HKDF-SHA256(Argon2id(PIN, salt; 19 MiB, 2 iteraciones) ‖ pepper, info = `docxan-backup-v2|user_id|document_id`); AAD = `DXN2|user_id|document_id`. Argon2id corre en un isolate. Un blob robado no se puede atacar por fuerza bruta offline sin el secreto del servidor, y no se puede mover a otro usuario/documento.
3. Pide una URL prefirmada PUT/GET (las PUT firman `content-length`, máx. 50 MiB).
4. Sube o descarga el ciphertext. El token S3 **nunca** viaja en el APK.

Los backups **DXN1** antiguos (`DXN1`, clave = Argon2id(PIN) 8 MiB) se siguen descifrando; las subidas nuevas siempre son DXN2. La Edge Function aplica rate limit por usuario (tabla `rate_limits`, `429` + `Retry-After`).

Clave de objeto: `{user_id}/{document_id}/{backup_id}.bin`

## Seguridad local

- **PIN:** tras 5 fallos seguidos, bloqueo de 30 s; cada fallo siguiente escala a 1 min, 5 min, 15 min y 1 h (tope). El contador vive en `SecureStore` (sobrevive a reinicios) y se reinicia al acertar o con biometría.
- **Capturas de pantalla:** Android usa `FLAG_SECURE` en `MainActivity` (sin capturas, grabación ni miniatura en recientes). iOS no tiene equivalente directo; pendiente.
- **Temporales en claro:** las capturas y OCR viven en `<temp>/docxan_scan/`. Se borran al consumirse (original de cámara/galería tras copiarlo, `ocr_N.jpg` tras el OCR, PNG/DOCX tras compartir, páginas al quitar/repetir/guardar la sesión). Al arrancar se borra todo `docxan_scan/` anterior al proceso y los temporales de plugins (`CAP*`, `image_picker*`, `scaled_*`, `share_plus/`) de más de 1 h; al pasar a segundo plano, lo mismo con más de 1 h, respetando las páginas de la sesión de escaneo abierta.

## Publicidad (AdMob, solo banner)

Docxan solo usa **un banner anchored adaptive** en `MainShell`, encima de la barra inferior, en Inicio, Carpetas, Buscar y Ajustes. No aparece en Escanear/edición ni en el documento/OCR. Ningún otro formato (interstitial, rewarded, app open, native, collapsible).

Código: `app/lib/core/ads/` (`AdConfig`, `AdService`, `widgets/docxan_banner_ad.dart`). Por defecto usa los IDs oficiales de prueba de Google.

Para producción:

- **App ID** (`ca-app-pub-…~…`): `ADMOB_APP_ID` como propiedad Gradle (`app/android/gradle.properties` o `flutter build apk --flavor prod -PADMOB_APP_ID=…`). Lo lee `manifestPlaceholders["admobAppId"]`.
- **Banner Ad Unit ID** (`ca-app-pub-…/…`): `ADMOB_ANDROID_BANNER_AD_UNIT_ID` en `app/env.json` (`--dart-define-from-file`).
- **Consentimiento:** integrar Google UMP antes de publicar si la audiencia/regiones lo exigen (pendiente, ver TODO en `AdService`).
- Nada de AdMob vive en Supabase.

## Flavors

| Flavor | applicationId        | entrypoint          |
|--------|----------------------|---------------------|
| dev    | app.docxan.dev       | lib/main_dev.dart   |
| prod   | app.docxan           | lib/main_prod.dart  |
