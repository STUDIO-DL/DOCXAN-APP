/// Credenciales públicas de backend. Solo se leen de `--dart-define` / `env.json`.
/// Nunca hardcodees valores reales aquí. Los secretos de R2 viven solo en
/// Supabase secrets (Edge Function `backup-signed-url`), nunca en la app.
class BackendEnv {
  const BackendEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleWebClientId,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleWebClientId;

  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get isGoogleConfigured =>
      isSupabaseConfigured && googleWebClientId.isNotEmpty;

  static const fromEnvironment = BackendEnv(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
  );
}
