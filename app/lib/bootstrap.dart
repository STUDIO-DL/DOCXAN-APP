import 'package:docxan/app/app.dart';
import 'package:docxan/app/flavor.dart';
import 'package:docxan/core/database/app_database.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/network/docxan_supabase.dart';
import 'package:docxan/core/notifications/push_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(FlavorConfig flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init(flavor);
  await DocxanSupabase.initialize(flavor);
  await PushNotifications.initialize();
  final database = await AppDatabase.open();
  runApp(
    ProviderScope(
      overrides: [
        flavorConfigProvider.overrideWithValue(flavor),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const DocxanApp(),
    ),
  );
}
