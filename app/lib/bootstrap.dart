import 'package:docxan/app/app.dart';
import 'package:docxan/app/flavor.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/network/docxan_supabase.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(FlavorConfig flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init(flavor);
  await DocxanSupabase.initialize(flavor);
  runApp(
    ProviderScope(
      overrides: [
        flavorConfigProvider.overrideWithValue(flavor),
      ],
      child: const DocxanApp(),
    ),
  );
}
