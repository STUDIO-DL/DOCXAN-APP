# Edge Function `push-send`

Envía una notificación FCM (HTTP v1) a todos los dispositivos del usuario autenticado. Los tokens viven en `public.device_tokens` y la app los registra con la RPC `register_device_token`.

## Secret

Firebase → Configuración del proyecto → Cuentas de servicio → Generar nueva clave privada. Luego, en PowerShell:

```powershell
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("RUTA\docxan-firebase-adminsdk.json"))
supabase secrets set FCM_SERVICE_ACCOUNT_B64=$b64
```

No subas ese JSON al repositorio.

## Contrato

```
POST /functions/v1/push-send
Authorization: Bearer <access token>
{ "title": "...", "body": "...", "data"?: { "clave": "valor" } }
```

Respuesta: `{ sent, failed }`. Los tokens que FCM marca como `UNREGISTERED` se borran.
