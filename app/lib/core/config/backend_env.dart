/// Credenciales de backend. Solo se leen de `--dart-define` / `env.json`.
/// Nunca hardcodees valores reales aquí.
class BackendEnv {
  const BackendEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleWebClientId,
    required this.r2Endpoint,
    required this.r2AccessKey,
    required this.r2SecretKey,
    required this.r2Bucket,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleWebClientId;
  final String r2Endpoint;
  final String r2AccessKey;
  final String r2SecretKey;
  final String r2Bucket;

  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get isGoogleConfigured =>
      isSupabaseConfigured && googleWebClientId.isNotEmpty;

  bool get isR2Configured {
    return r2Endpoint.isNotEmpty &&
        r2AccessKey.isNotEmpty &&
        r2SecretKey.isNotEmpty &&
        r2Bucket.isNotEmpty;
  }

  static const fromEnvironment = BackendEnv(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    r2Endpoint: String.fromEnvironment('R2_ENDPOINT'),
    r2AccessKey: String.fromEnvironment('R2_ACCESS_KEY'),
    r2SecretKey: String.fromEnvironment('R2_SECRET_KEY'),
    r2Bucket: String.fromEnvironment('R2_BUCKET'),
  );
}
