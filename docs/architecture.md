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

1. La app cifra el blob (AES-256-GCM, clave derivada con Argon2id del PIN).
2. Llama a `supabase/functions/backup-signed-url` con el JWT de sesión.
3. Recibe una URL prefirmada PUT/GET.
4. Sube o descarga el ciphertext. El token S3 **nunca** viaja en el APK.

Clave de objeto: `{user_id}/{document_id}/{backup_id}.bin`

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
