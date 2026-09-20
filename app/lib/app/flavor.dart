import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor { dev, prod }

class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.displayName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleWebClientId,
  });

  final AppFlavor flavor;
  final String displayName;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleWebClientId;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isGoogleConfigured => googleWebClientId.isNotEmpty;

  static const dev = FlavorConfig(
    flavor: AppFlavor.dev,
    displayName: 'Docxan Dev',
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
  );

  static const prod = FlavorConfig(
    flavor: AppFlavor.prod,
    displayName: 'Docxan',
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
  );
}

final flavorConfigProvider = Provider<FlavorConfig>((ref) {
  throw StateError('flavorConfigProvider must be overridden in bootstrap');
});
