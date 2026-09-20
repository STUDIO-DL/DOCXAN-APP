# Edge Function `backup-signed-url`

Emite URLs prefirmadas S3 para Cloudflare R2. El token S3 **nunca** viaja en la app.

## Secrets

En Supabase → Edge Functions → Secrets:

- `R2_ACCOUNT_ID`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET` (`doxan-backups-dev` o `doxan-backups-prod`)

`SUPABASE_URL`, `SUPABASE_ANON_KEY` y `SUPABASE_SERVICE_ROLE_KEY` ya los inyecta la plataforma.

## Contrato

```
POST /functions/v1/backup-signed-url
Authorization: Bearer <access token>
{ "action": "upload"|"download"|"delete", "documentId"?, "backupId"?, "r2Key"? }
```

Respuesta: `{ url, r2Key, expiresIn, method }`

Clave de objeto: `{user_id}/{document_id}/{backup_id}.bin`
