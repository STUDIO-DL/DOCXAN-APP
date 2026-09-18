# backup-signed-url
#
# Contrato:
#   POST / { action: "upload"|"download"|"delete", documentId, backupId? }
#   Header: Authorization: Bearer <supabase access token>
#   Response: { url, r2Key, expiresIn }
#
# El secreto R2 vive en Supabase secrets, nunca en la app.
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) {
    return json({ error: "unauthorized" }, 401);
  }

  return json(
    {
      error: "not_configured",
      message:
        "Crea la cuenta Cloudflare, buckets doxan-backups-dev/prod y los secrets R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY.",
    },
    501,
  );
});

function json(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
