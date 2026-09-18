import 'package:doxan/app/flavor.dart';
import 'package:doxan/core/logging/app_logger.dart';
import 'package:doxan/core/network/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class DoxanSupabase {
  static bool isReady = false;

  static Future<void> initialize(FlavorConfig flavor) async {
    final config = SupabaseConfig(
      url: flavor.supabaseUrl,
      anonKey: flavor.supabaseAnonKey,
    );
    if (!config.isConfigured) {
      AppLogger.debug('Supabase omitido: faltan SUPABASE_URL / SUPABASE_ANON_KEY');
      isReady = false;
      return;
    }

    await Supabase.initialize(
      url: config.url,
      publishableKey: config.anonKey,
    );
    isReady = true;
    AppLogger.debug('Supabase listo');
  }

  static SupabaseClient get client {
    if (!isReady) {
      throw StateError('Supabase no está inicializado');
    }
    return Supabase.instance.client;
  }
}
