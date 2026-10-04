// push-send
//
// POST / { title: string, body: string, data?: Record<string, string> }
// Header: Authorization: Bearer <supabase access token>
// Envía una notificación FCM a todos los dispositivos del usuario autenticado.
//
// Secret: FCM_SERVICE_ACCOUNT_B64 (JSON de la cuenta de servicio de Firebase, en base64).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

let cachedToken: { value: string; expiresAt: number } | null = null;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const accountB64 = Deno.env.get("FCM_SERVICE_ACCOUNT_B64") ?? "";
  if (!supabaseUrl || !serviceKey) {
    return json({ error: "supabase_not_configured" }, 500);
  }
  if (!accountB64) {
    return json({ error: "not_configured", message: "Falta FCM_SERVICE_ACCOUNT_B64." }, 501);
  }

  const userClient = createClient(supabaseUrl, anonKey || serviceKey, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser(
    auth.slice("Bearer ".length),
  );
  if (userError || !userData.user) {
    return json({ error: "unauthorized" }, 401);
  }

  let body: Record<string, unknown> = {};
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }
  const title = String(body.title ?? "").slice(0, 120);
  const text = String(body.body ?? "").slice(0, 500);
  if (!title && !text) {
    return json({ error: "empty_message" }, 400);
  }
  const data = sanitizeData(body.data);

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: rows, error: rowsError } = await admin
    .from("device_tokens")
    .select("token")
    .eq("user_id", userData.user.id);
  if (rowsError) {
    return json({ error: "tokens_unavailable" }, 500);
  }
  const tokens = (rows ?? []).map((row) => row.token as string);
  if (tokens.length === 0) {
    return json({ sent: 0, failed: 0 }, 200);
  }

  let account: ServiceAccount;
  try {
    account = JSON.parse(atob(accountB64));
  } catch {
    return json({ error: "invalid_service_account" }, 500);
  }
  let accessToken: string;
  try {
    accessToken = await googleAccessToken(account);
  } catch (error) {
    return json({ error: "google_oauth_failed", message: String(error) }, 502);
  }

  let sent = 0;
  const stale: string[] = [];
  for (const token of tokens) {
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body: text },
            data,
            android: {
              priority: "high",
              notification: { channel_id: "docxan_default" },
            },
          },
        }),
      },
    );
    if (response.ok) {
      sent += 1;
      continue;
    }
    const detail = await response.text();
    if (response.status === 404 || detail.includes("UNREGISTERED")) {
      stale.push(token);
    }
  }

  if (stale.length > 0) {
    await admin.from("device_tokens").delete().in("token", stale);
  }

  return json({ sent, failed: tokens.length - sent }, 200);
});

function sanitizeData(raw: unknown): Record<string, string> {
  if (!raw || typeof raw !== "object") return {};
  const out: Record<string, string> = {};
  for (const [key, value] of Object.entries(raw as Record<string, unknown>)) {
    out[key] = String(value);
  }
  return out;
}

async function googleAccessToken(account: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expiresAt - 60 > now) {
    return cachedToken.value;
  }
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(claims))}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(account.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const assertion = `${unsigned}.${base64url(new Uint8Array(signature))}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!response.ok) {
    throw new Error(`google_oauth_${response.status}`);
  }
  const payload = await response.json();
  cachedToken = { value: payload.access_token, expiresAt: now + payload.expires_in };
  return payload.access_token;
}

function pemToDer(pem: string): ArrayBuffer {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const bytes = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
  return bytes.buffer;
}

function base64url(input: string | Uint8Array): string {
  const bytes = typeof input === "string" ? new TextEncoder().encode(input) : input;
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
