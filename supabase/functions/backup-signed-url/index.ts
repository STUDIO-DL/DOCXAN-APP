// backup-signed-url
//
// POST / { action: "upload"|"download"|"delete", documentId?, backupId?, r2Key? }
// Header: Authorization: Bearer <supabase access token>
// Response: { url, r2Key, expiresIn }
//
// El secreto R2 vive en Supabase secrets, nunca en la app.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { AwsClient } from "https://esm.sh/aws4fetch@1.0.20";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

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
  if (!supabaseUrl || (!serviceKey && !anonKey)) {
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

  const action = String(body.action ?? "");
  const documentId = body.documentId ? String(body.documentId) : "";
  const backupId = String(body.backupId ?? "current");
  const requestedKey = body.r2Key ? String(body.r2Key) : "";

  const accountId = Deno.env.get("R2_ACCOUNT_ID") ?? "";
  const accessKey = Deno.env.get("R2_ACCESS_KEY_ID") ?? "";
  const secretKey = Deno.env.get("R2_SECRET_ACCESS_KEY") ?? "";
  const bucket = Deno.env.get("R2_BUCKET") ?? "";
  // Buckets con jurisdicción (p. ej. "eu") viven en <cuenta>.<jurisdicción>.r2...
  const jurisdiction = (Deno.env.get("R2_JURISDICTION") ?? "").trim().toLowerCase();
  if (!accountId || !accessKey || !secretKey || !bucket) {
    return json(
      {
        error: "not_configured",
        message:
          "Faltan secrets R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET.",
      },
      501,
    );
  }

  const r2Key = requestedKey || `${userId}/${documentId}/${backupId}.bin`;
  if (!r2Key.startsWith(`${userId}/`)) {
    return json({ error: "forbidden_key" }, 403);
  }

  if (documentId) {
    const admin = createClient(supabaseUrl, serviceKey || anonKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: document } = await admin
      .from("documents")
      .select("id, user_id")
      .eq("id", documentId)
      .maybeSingle();
    if (document && document.user_id !== userId) {
      return json({ error: "forbidden_document" }, 403);
    }
  }

  const method = methodFor(action);
  if (!method) {
    return json({ error: "unsupported_action" }, 400);
  }

  const aws = new AwsClient({
    accessKeyId: accessKey,
    secretAccessKey: secretKey,
    service: "s3",
    region: "auto",
  });
  const expiresIn = 300;
  const host = jurisdiction
    ? `${accountId}.${jurisdiction}.r2.cloudflarestorage.com`
    : `${accountId}.r2.cloudflarestorage.com`;
  const objectUrl = `https://${host}/${bucket}/${r2Key}`;
  const signed = await aws.sign(
    new Request(`${objectUrl}?X-Amz-Expires=${expiresIn}`, { method }),
    { aws: { signQuery: true } },
  );

  return json({ url: signed.url, r2Key, expiresIn, method });
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

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
