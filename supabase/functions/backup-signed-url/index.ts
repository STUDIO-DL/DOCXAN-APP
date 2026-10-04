// backup-signed-url
//
// POST / { action: "upload"|"download"|"delete", documentId?, backupId?, r2Key?, size? }
//   -> { url, r2Key, expiresIn, method }
// POST / { action: "backup_key" }
//   -> { key, version }  (per-user 32-byte backup pepper, base64)
// Header: Authorization: Bearer <supabase access token>
//
// Los secretos (R2, BACKUP_PEPPER_SECRET) viven en Supabase secrets, nunca en
// la app. Rate limit por usuario vía public.rate_limit_hit (service role).
// Sin CORS: solo la app móvil llama a esta función; los navegadores quedan
// bloqueados por no devolver Access-Control-Allow-Origin.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const KEY =
  /^([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\/(?:current|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\.bin$/i;

// Must match R2StorageService.maxUploadBytes in the app.
const MAX_UPLOAD_BYTES = 50 * 1024 * 1024;
const URL_EXPIRES_SECONDS = 300;
const RATE_WINDOW_SECONDS = 600;
const SIGNED_URL_LIMIT = 300;
const BACKUP_KEY_LIMIT = 10;
const MIN_PEPPER_SECRET_LENGTH = 32;

const encoder = new TextEncoder();

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  if (!supabaseUrl || !serviceKey) {
    return json({ error: "supabase_not_configured" }, 500);
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
  const userId = userData.user.id;

  let body: Record<string, unknown> = {};
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }
  if (!body || typeof body !== "object") {
    return json({ error: "invalid_json" }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const action = String(body.action ?? "");

  if (action === "backup_key") {
    const pepperSecret = Deno.env.get("BACKUP_PEPPER_SECRET") ?? "";
    if (pepperSecret.length < MIN_PEPPER_SECRET_LENGTH) {
      console.error("backup-signed-url: backup key not configured");
      return json({ error: "not_configured" }, 501);
    }
    const limited = await rateLimit(
      admin,
      userId,
      "backup_key",
      BACKUP_KEY_LIMIT,
    );
    if (limited) return limited;
    const key = await hmacSha256(
      encoder.encode(pepperSecret),
      encoder.encode(`docxan-backup-pepper/v1/${userId}`),
    );
    return json({ key: base64(key), version: 1 }, 200);
  }

  const method = methodFor(action);
  if (!method) {
    return json({ error: "unsupported_action" }, 400);
  }

  const documentId = body.documentId ? String(body.documentId) : "";
  const backupId = String(body.backupId ?? "current");
  const requestedKey = body.r2Key ? String(body.r2Key) : "";

  if (!requestedKey && !UUID.test(documentId)) {
    return json({ error: "invalid_document" }, 400);
  }
  if (!requestedKey && backupId !== "current" && !UUID.test(backupId)) {
    return json({ error: "invalid_backup" }, 400);
  }

  let size = 0;
  if (method === "PUT") {
    const raw = body.size;
    if (
      typeof raw !== "number" || !Number.isInteger(raw) || raw < 1
    ) {
      return json({ error: "invalid_size" }, 400);
    }
    if (raw > MAX_UPLOAD_BYTES) {
      return json({ error: "too_large", maxBytes: MAX_UPLOAD_BYTES }, 413);
    }
    size = raw;
  }

  const accountId = Deno.env.get("R2_ACCOUNT_ID") ?? "";
  const accessKey = Deno.env.get("R2_ACCESS_KEY_ID") ?? "";
  const secretKey = Deno.env.get("R2_SECRET_ACCESS_KEY") ?? "";
  const bucket = Deno.env.get("R2_BUCKET") ?? "";
  // Buckets con jurisdicción (p. ej. "eu") viven en <cuenta>.<jurisdicción>.r2...
  const jurisdiction = (Deno.env.get("R2_JURISDICTION") ?? "").trim().toLowerCase();
  if (!accountId || !accessKey || !secretKey || !bucket) {
    console.error("backup-signed-url: storage not configured");
    return json({ error: "not_configured" }, 501);
  }

  const r2Key = requestedKey || `${userId}/${documentId}/${backupId}.bin`;
  const keyMatch = KEY.exec(r2Key);
  if (!keyMatch || keyMatch[1] !== userId) {
    return json({ error: "forbidden_key" }, 403);
  }

  const limited = await rateLimit(
    admin,
    userId,
    "signed_url",
    SIGNED_URL_LIMIT,
  );
  if (limited) return limited;

  if (documentId && UUID.test(documentId)) {
    const { data: document } = await admin
      .from("documents")
      .select("id, user_id")
      .eq("id", documentId)
      .maybeSingle();
    if (document && document.user_id !== userId) {
      return json({ error: "forbidden_document" }, 403);
    }
  }

  const url = await presign({
    method,
    host: jurisdiction
      ? `${accountId}.${jurisdiction}.r2.cloudflarestorage.com`
      : `${accountId}.r2.cloudflarestorage.com`,
    path: `/${bucket}/${r2Key}`,
    accessKey,
    secretKey,
    expiresIn: URL_EXPIRES_SECONDS,
    contentLength: method === "PUT" ? size : undefined,
  });

  return json({ url, r2Key, expiresIn: URL_EXPIRES_SECONDS, method }, 200);
});

function methodFor(action: string): string | null {
  switch (action) {
    case "upload":
      return "PUT";
    case "download":
      return "GET";
    case "delete":
      return "DELETE";
    default:
      return null;
  }
}

// Returns a 429 response when the user is over the limit, null otherwise.
// Fails closed if the limiter is unavailable.
async function rateLimit(
  // deno-lint-ignore no-explicit-any
  admin: any,
  userId: string,
  bucket: string,
  limit: number,
): Promise<Response | null> {
  const { data, error } = await admin.rpc("rate_limit_hit", {
    p_user: userId,
    p_bucket: bucket,
    p_limit: limit,
    p_window_seconds: RATE_WINDOW_SECONDS,
  });
  if (error || typeof data !== "number") {
    console.error("backup-signed-url: rate limiter unavailable");
    return json({ error: "rate_limit_unavailable" }, 503);
  }
  if (data > 0) {
    return json({ error: "rate_limited", retryAfter: data }, 429, {
      "Retry-After": String(data),
    });
  }
  return null;
}

// AWS SigV4 query presigning. aws4fetch never signs content-length, so the
// upload size limit needs our own signer: R2 then rejects any PUT whose
// Content-Length differs from the signed value.
async function presign(opts: {
  method: string;
  host: string;
  path: string;
  accessKey: string;
  secretKey: string;
  expiresIn: number;
  contentLength?: number;
}): Promise<string> {
  const region = "auto";
  const service = "s3";
  const now = new Date();
  const amzDate = now.toISOString().replace(/[:-]|\.\d{3}/g, "");
  const dateStamp = amzDate.slice(0, 8);
  const scope = `${dateStamp}/${region}/${service}/aws4_request`;

  const canonicalUri = opts.path
    .split("/")
    .map((segment) => rfc3986(segment))
    .join("/");

  const headers: [string, string][] = [];
  if (opts.contentLength !== undefined) {
    headers.push(["content-length", String(opts.contentLength)]);
  }
  headers.push(["host", opts.host]);
  const signedHeaders = headers.map(([name]) => name).join(";");
  const canonicalHeaders = headers
    .map(([name, value]) => `${name}:${value}\n`)
    .join("");

  const query: [string, string][] = [
    ["X-Amz-Algorithm", "AWS4-HMAC-SHA256"],
    ["X-Amz-Credential", `${opts.accessKey}/${scope}`],
    ["X-Amz-Date", amzDate],
    ["X-Amz-Expires", String(opts.expiresIn)],
    ["X-Amz-SignedHeaders", signedHeaders],
  ];
  const canonicalQuery = query
    .map(([k, v]) => [rfc3986(k), rfc3986(v)])
    .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
    .map(([k, v]) => `${k}=${v}`)
    .join("&");

  const canonicalRequest = [
    opts.method,
    canonicalUri,
    canonicalQuery,
    canonicalHeaders,
    signedHeaders,
    "UNSIGNED-PAYLOAD",
  ].join("\n");

  const stringToSign = [
    "AWS4-HMAC-SHA256",
    amzDate,
    scope,
    hex(await sha256(encoder.encode(canonicalRequest))),
  ].join("\n");

  const kDate = await hmacSha256(
    encoder.encode(`AWS4${opts.secretKey}`),
    encoder.encode(dateStamp),
  );
  const kRegion = await hmacSha256(kDate, encoder.encode(region));
  const kService = await hmacSha256(kRegion, encoder.encode(service));
  const kSigning = await hmacSha256(kService, encoder.encode("aws4_request"));
  const signature = hex(
    await hmacSha256(kSigning, encoder.encode(stringToSign)),
  );

  return `https://${opts.host}${canonicalUri}?${canonicalQuery}` +
    `&X-Amz-Signature=${signature}`;
}

function rfc3986(value: string): string {
  return encodeURIComponent(value).replace(
    /[!'()*]/g,
    (c) => `%${c.charCodeAt(0).toString(16).toUpperCase()}`,
  );
}

async function hmacSha256(
  key: Uint8Array,
  message: Uint8Array,
): Promise<Uint8Array> {
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    key,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  return new Uint8Array(await crypto.subtle.sign("HMAC", cryptoKey, message));
}

async function sha256(data: Uint8Array): Promise<Uint8Array> {
  return new Uint8Array(await crypto.subtle.digest("SHA-256", data));
}

function hex(bytes: Uint8Array): string {
  return Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
}

function base64(bytes: Uint8Array): string {
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary);
}

function json(
  body: unknown,
  status: number,
  extra: Record<string, string> = {},
) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
      ...extra,
    },
  });
}
