# Arquitectura Doxan

Cliente-servidor **offline-first**. Drift (local) es la fuente de verdad diaria. Supabase guarda metadatos no sensibles. Cloudflare R2 guarda **solo ciphertext**.

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
| dev    | app.doxan.dev        | lib/main_dev.dart   |
| prod   | app.doxan            | lib/main_prod.dart  |
