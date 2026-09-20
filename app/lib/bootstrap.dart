import 'package:doxan/app/app.dart';
import 'package:doxan/app/flavor.dart';
import 'package:doxan/core/database/app_database.dart';
import 'package:doxan/core/logging/app_logger.dart';
import 'package:doxan/core/network/doxan_supabase.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(FlavorConfig flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init(flavor);
  await DoxanSupabase.initialize(flavor);
  final database = await AppDatabase.open();
  runApp(
    ProviderScope(
      overrides: [
        flavorConfigProvider.overrideWithValue(flavor),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const DoxanApp(),
    ),
  );
}
