# Docxan

App Android offline-first para escanear, organizar y respaldar documentos.

## Estructura

- `app/` — Flutter (`applicationId`: `app.docxan`, `minSdk`: 26)
- `supabase/` — Auth, Postgres (metadatos) y Edge Function de URLs prefirmadas R2
- `legal/` — política de privacidad y términos (Play)
- `tool/` — smoke test de Cloudflare R2
- `packages/` — vacío en el MVP; extracción de módulos después

Reglas: un feature no importa a otro. Lo compartido vive en `app/lib/core`. `app/lib/app` es el composition root.

## Arranque local

```bash
cd app
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

Producción:

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

## Cuentas (día 1)

1. Google Play Console
2. **Supabase** — guía: [docs/supabase.md](docs/supabase.md)
3. Cloudflare R2 (buckets `docxan-backups-dev` / `docxan-backups-prod`) — hecho
4. Google Cloud OAuth (SHA-1 debug + Play App Signing)

Copia `app/env.example.json` a `app/env.json` (no se sube al repo).

Con Supabase:

```bash
cd app
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env.json
```

## Stack

Flutter, Riverpod, go_router, Drift (próximo), ML Kit OCR, OpenCV, AES-256-GCM, Supabase, Cloudflare R2.
