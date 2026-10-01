import 'package:docxan/app/app.dart';
import 'package:docxan/app/flavor.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/locale/app_locale_store.dart';
import 'package:docxan/core/session/session_store.dart';
import 'package:docxan/core/storage/local_file_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('onboarding aparece tras el splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localeTestValue = const Locale('es');
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flavorConfigProvider.overrideWithValue(FlavorConfig.dev),
          sessionStoreProvider.overrideWithValue(MemorySessionStore()),
          localFileStoreProvider.overrideWithValue(MemoryLocalFileStore()),
          localeStoreProvider.overrideWithValue(MemoryLocaleStore()),
        ],
        child: const DocxanApp(),
      ),
    );

    expect(find.byType(Image), findsOneWidget);

    await tester.pump(AppConstants.splashDuration);
    await tester.pumpAndSettle();

    expect(find.text('Empezar'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
