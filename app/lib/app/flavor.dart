import 'package:doxan/core/config/backend_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor { dev, prod }

class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.displayName,
    required this.backend,
  });

  final AppFlavor flavor;
  final String displayName;
  final BackendEnv backend;

  String get supabaseUrl => backend.supabaseUrl;
  String get supabaseAnonKey => backend.supabaseAnonKey;
  String get googleWebClientId => backend.googleWebClientId;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isGoogleConfigured => backend.isGoogleConfigured;
  bool get isR2Configured => backend.isR2Configured;

  static const dev = FlavorConfig(
    flavor: AppFlavor.dev,
    displayName: 'Docxan Dev',
    backend: BackendEnv.fromEnvironment,
  );

  static const prod = FlavorConfig(
    flavor: AppFlavor.prod,
    displayName: 'Docxan',
    backend: BackendEnv.fromEnvironment,
  );
}

final flavorConfigProvider = Provider<FlavorConfig>((ref) {
  throw StateError('flavorConfigProvider must be overridden in bootstrap');
});
