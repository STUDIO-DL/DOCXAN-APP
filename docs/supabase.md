# Alta de Supabase (Doxan)

R2 ya está. Ahora Auth + Postgres (solo metadatos, nunca OCR ni blobs).

## 1. Crear el proyecto

1. Entra en [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. **New project**
3. Name: `doxan`
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

Google y el resto de providers: **Disabled** hasta tener SHA-1 de Android.

**Save changes.**

## 2b. Google Sign-In (nativo Android)

Hace falta un proyecto en [Google Cloud Console](https://console.cloud.google.com/). El **secret** del cliente Web solo vive en Supabase, nunca en la app.

### Google Cloud

1. Crea (o elige) un proyecto, p. ej. `doxan`.
2. **APIs & Services → OAuth consent screen**
   - User type: External
   - App name: Doxan
   - Support email: el tuyo
   - Scopes: `email`, `profile`, `openid`
3. **Credentials → Create credentials → OAuth client ID**

**A) Web application** (este es el que va en Supabase y en `env.json`)

- Name: `Doxan Web`
- Authorized redirect URIs:
  - `https://<PROJECT_REF>.supabase.co/auth/v1/callback`
- Copia **Client ID** y **Client secret**

**B) Android** — uno por flavor

| Name | Package name | SHA-1 |
|------|----------------|-------|
| Doxan Android Dev | `app.doxan.dev` | SHA-1 del keystore **debug** |
| Doxan Android | `app.doxan` | SHA-1 de **Play App Signing** (y debug si pruebas prod local) |

SHA-1 debug (en tu máquina, no lo pegues en el chat):

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
"GOOGLE_WEB_CLIENT_ID": "xxxxx.apps.googleusercontent.com"
```

Es el Client ID **Web**, no el de Android. Relanza **Doxan (dev + Supabase)**.

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

O en Cursor: **Doxan (dev + Supabase)**.

## 5. Secrets de R2 (más adelante)

Los tokens S3 de Cloudflare van en **Edge Function secrets**, no en `env.json`.
