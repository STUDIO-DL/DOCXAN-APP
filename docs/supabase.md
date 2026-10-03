# Alta de Supabase (Docxan)

R2 ya está. Ahora Auth + Postgres (solo metadatos, nunca OCR ni blobs).

## 1. Crear el proyecto

1. Entra en [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. **New project**
3. Name: `docxan`
4. Database password: genérala y **guárdala** (no va en la app)
5. Region: **Central Europe (Frankfurt)** — misma zona que R2 EU
6. Plan **Free**
7. Create project (tarda ~2 min)

## 1b. Security (al crear o en Data API)

- **Enable Data API:** ON. `supabase_flutter` usa esta API REST para metadatos (carpetas, sync). Auth también encaja con el cliente.
- **Automatically expose new tables:** OFF. Solo exponemos `folders`, `documents` y `backups` (la migración ya pone RLS). Tablas nuevas no deben salir solas.
- **Enable automatic RLS:** ON. Si se crea una tabla en `public` sin política, queda bloqueada por defecto.

## 2. Auth

**Authentication → Sign In / Providers**

User Signups:

- **Allow new users to sign up:** ON
- **Allow manual linking:** OFF
- **Allow anonymous sign-ins:** OFF (el invitado es local en la app, no un user anónimo de Supabase)
- **Confirm email:** ON

Email (Enabled):

- **Enable email provider:** ON
- **Secure email change:** ON
- **Secure password change:** ON
- **Require current password when updating:** ON
- **Minimum password length:** `8`
- **Password requirements:** No required characters (MVP)
- **Email OTP expiration:** `3600`
- **Email OTP length:** `8`

Google: **Enable** cuando existan el Client ID Web y el secret (sección 2b).

**Save changes.**

## 2b. Google Sign-In (nativo Android)

Hace falta un proyecto en [Google Cloud Console](https://console.cloud.google.com/). El **secret** del cliente Web solo vive en Supabase, nunca en la app.

### Google Cloud

1. Crea (o elige) un proyecto, p. ej. `docxan`.
2. **APIs & Services → OAuth consent screen**
   - User type: External
   - App name: Docxan
   - Support email: el tuyo
   - Scopes: `email`, `profile`, `openid`
3. **Credentials → Create credentials → OAuth client ID**

**A) Web application** (este es el que va en Supabase y en `env.json`)

- Name: `Docxan Web`
- Authorized redirect URIs:
  - `https://rwfdwkdlqkowvptcpyvs.supabase.co/auth/v1/callback`
- Copia **Client ID** y **Client secret**

**B) Android** — uno por flavor

| Name | Package name | SHA-1 |
|------|----------------|-------|
| Docxan Android Dev | `app.docxan.dev` | SHA-1 del keystore **debug** |
| Docxan Android | `app.docxan` | SHA-1 de **Play App Signing** (y debug si pruebas prod local) |

SHA-1 debug: `B7:FA:59:14:D9:3F:4E:32:B3:E4:0E:3A:43:8E:E8:68:A0:90:54:03`

Para regenerarlo:

```bat
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android
```

Si `keytool` no está en el PATH, usa el de Android Studio: `...\Android Studio\jbr\bin\keytool.exe`.

### Supabase → Sign In / Providers → Google → Enable

- **Client ID:** el de tipo **Web**
- **Client Secret:** el de tipo **Web**
- **Authorized Client IDs** (si aparece): Web Client ID + Android Client IDs, separados por coma
- **Skip nonce check** (o equivalente nativo): **ON** — sin esto el `idToken` de Android suele fallar

Save.

### App

En `app/env.json`:

```json
{
  "SUPABASE_URL": "https://rwfdwkdlqkowvptcpyvs.supabase.co",
  "SUPABASE_ANON_KEY": "TU_ANON_PUBLIC",
  "GOOGLE_WEB_CLIENT_ID": "xxxxx.apps.googleusercontent.com"
}
```

Es el Client ID **Web**, no el de Android. Relanza **Docxan (dev + Supabase)**.

## 3. Tablas

**SQL Editor → New query**, pega el contenido de `supabase/migrations/20260917120000_init.sql` y Run.

## 4. Claves de la app

**Project Settings → API**

- Project URL → `SUPABASE_URL`
- `anon` `public` → `SUPABASE_ANON_KEY`

Nunca uses `service_role` en el móvil.

```bash
cd app
copy env.example.json env.json
```

Edita `app/env.json` (está en `.gitignore`) y lanza:

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env.json
```

O en Cursor: **Docxan (dev + Supabase)**.

## 5. Secrets de R2

Los tokens S3 de Cloudflare van en **Edge Function secrets**, no en `env.json`:

- `R2_ACCOUNT_ID`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET` (`doxan-backups-dev` o `doxan-backups-prod`)

Despliega `supabase/functions/backup-signed-url` y ejecuta también
`supabase/migrations/20260919120000_documents_library.sql` (añade
`deleted_at`, `page_count`, `is_favorite`).

## 6. Clave de servidor de backups y rate limit

Los backups nuevos (formato DXN2) combinan el PIN con una clave por usuario
que deriva la Edge Function a partir de un secreto maestro:

- `BACKUP_PEPPER_SECRET` — aleatorio, ≥ 32 caracteres, distinto en dev y prod.
  **No lo pierdas ni lo cambies**: sin él no se pueden descifrar los backups DXN2.
  Guarda una copia fuera de Supabase.

```bash
supabase secrets set BACKUP_PEPPER_SECRET="$(openssl rand -base64 48)"
supabase db push                       # aplica 20261003120000_rate_limits.sql
supabase functions deploy backup-signed-url
```

La migración crea `public.rate_limits` (RLS sin políticas) y
`public.rate_limit_hit(...)` (`security definer`, solo `service_role`). La
función limita a 300 URLs firmadas y 10 peticiones de clave por usuario cada
10 minutos (`429` + `Retry-After`), y las subidas a 50 MiB (tamaño firmado en
la URL). Detalles en `supabase/functions/backup-signed-url/README.md`.
