import 'package:docxan/app/app.dart';
import 'package:docxan/app/flavor.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding aparece tras el splash', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flavorConfigProvider.overrideWithValue(FlavorConfig.dev),
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
