import 'dart:async';

import 'package:docxan/app/app.dart';
import 'package:docxan/app/flavor.dart';
import 'package:docxan/core/ads/ad_service.dart';
import 'package:docxan/core/database/app_database.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/network/docxan_supabase.dart';
import 'package:docxan/core/notifications/push_notifications.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(FlavorConfig flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init(flavor);
  // The scan session lives in memory only, so nothing in our scan cache
  // from a previous process can still be in use.
  final launchedAt = DateTime.now();
  unawaited(
    PathLocalFileStore().sweepTemps(
      scanCutoff: launchedAt.subtract(const Duration(seconds: 5)),
      pluginCutoff: launchedAt.subtract(const Duration(hours: 1)),
    ),
  );
  await DocxanSupabase.initialize(flavor);
  await PushNotifications.initialize();
  unawaited(AdService.initialize());
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
