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

## Flavors

| Flavor | applicationId        | entrypoint          |
|--------|----------------------|---------------------|
| dev    | app.docxan.dev       | lib/main_dev.dart   |
| prod   | app.docxan           | lib/main_prod.dart  |
