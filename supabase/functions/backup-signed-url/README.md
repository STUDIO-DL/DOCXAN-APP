# Edge Function `backup-signed-url`

Emite URLs prefirmadas S3 para Cloudflare R2 y la clave de servidor ("pepper")
de los backups. El token S3 y el secreto del pepper **nunca** viajan en la app.

## Secrets

En Supabase → Edge Functions → Secrets:

- `R2_ACCOUNT_ID`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET` (`docxan-backups-dev` o `docxan-backups-prod`)
- `BACKUP_PEPPER_SECRET` — secreto maestro (≥ 32 caracteres, aleatorio, p. ej.
  `openssl rand -base64 48`). **No se puede rotar ni perder**: sin él los
  backups DXN2 existentes no se pueden descifrar. Guárdalo también en un gestor
  de secretos fuera de Supabase. Usa un valor distinto por proyecto (dev/prod).

```bash
supabase secrets set BACKUP_PEPPER_SECRET="$(openssl rand -base64 48)"
```

`SUPABASE_URL`, `SUPABASE_ANON_KEY` y `SUPABASE_SERVICE_ROLE_KEY` ya los inyecta la plataforma
(el service role se usa para el rate limit y la comprobación de propiedad).

Requiere la migración `20261003120000_rate_limits.sql` (`public.rate_limit_hit`).
Sin ella la función responde `503 rate_limit_unavailable` (falla cerrada).

## Contrato

```
POST /functions/v1/backup-signed-url
Authorization: Bearer <access token>
{ "action": "upload"|"download"|"delete", "documentId"?, "backupId"?, "r2Key"?, "size"? }
```

Respuesta: `{ url, r2Key, expiresIn, method }`

- `upload` exige `size` (bytes exactos del blob, 1 … 50 MiB). La URL se firma
  con `content-length`, así R2 rechaza cualquier PUT de otro tamaño.
  Sin `size` → `400 invalid_size`; > 50 MiB → `413 too_large`.

```
{ "action": "backup_key" }
```

Respuesta: `{ key, version: 1 }` — `key` = base64 de
`HMAC-SHA256(BACKUP_PEPPER_SECRET, "docxan-backup-pepper/v1/" + user_id)` (32 bytes).
No se guarda en BD; la app la cachea solo en memoria. Sin secreto → `501 not_configured`.

Clave de objeto: `{user_id}/{document_id}/{backup_id}.bin`

## Límites

| Bucket       | Límite              | Acciones                     |
|--------------|---------------------|------------------------------|
| `signed_url` | 300 / 10 min / user | upload, download, delete     |
| `backup_key` | 10 / 10 min / user  | backup_key                   |

Al superarlo: `429 rate_limited` con cabecera `Retry-After` (segundos).
URLs prefirmadas válidas 300 s.

## CORS

Sin CORS: la única cliente es la app móvil (no aplica CORS). No se envía
`Access-Control-Allow-Origin`, de modo que una web ajena no puede usar el JWT
de un usuario desde el navegador. `OPTIONS` responde `204` sin cabeceras.
