# Guarda en Supabase las claves S3 de R2 a partir del token de Cloudflare (cfat_...).
# Access Key ID = id del token. Secret Access Key = SHA-256 del valor del token.
# Uso: powershell -ExecutionPolicy Bypass -File tool\set_r2_secrets.ps1

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

$token = (Read-Host "Pega el token de Cloudflare (empieza por cfat_)").Trim()
if (-not $token) { Write-Host "No pegaste nada." -ForegroundColor Red; exit 1 }

$headers = @{ Authorization = "Bearer $token" }
$tokenId = $null
try {
  $tokenId = (Invoke-RestMethod "https://api.cloudflare.com/client/v4/user/tokens/verify" -Headers $headers).result.id
} catch {}
if (-not $tokenId) {
  $accountId = (Read-Host "Pega el Account ID de Cloudflare (32 caracteres, pagina principal de R2)").Trim()
  try {
    $tokenId = (Invoke-RestMethod "https://api.cloudflare.com/client/v4/accounts/$accountId/tokens/verify" -Headers $headers).result.id
  } catch {
    Write-Host "Cloudflare no reconoce ese token. Revisa que este activo y copiado entero." -ForegroundColor Red
    exit 1
  }
}

$sha = [System.Security.Cryptography.SHA256]::Create()
$secret = ([System.BitConverter]::ToString($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($token)))).Replace("-", "").ToLower()

Write-Host "Access Key ID: $($tokenId.Length) caracteres. Secret: $($secret.Length) caracteres."
if ($tokenId.Length -ne 32 -or $secret.Length -ne 64) {
  Write-Host "Las longitudes no cuadran (deben ser 32 y 64). No se ha guardado nada." -ForegroundColor Red
  exit 1
}

supabase secrets set R2_ACCESS_KEY_ID=$tokenId R2_SECRET_ACCESS_KEY=$secret
Write-Host "Listo. Pulsa Sync en Docxan." -ForegroundColor Green
