import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/core/locale/app_locale_controller.dart';
import 'package:docxan/core/locale/app_locale_store.dart';
import 'package:docxan/core/locale/app_locales.dart';
import 'package:docxan/core/widgets/language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SettingsLanguageHarness extends ConsumerWidget {
  const _SettingsLanguageHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrideCode = ref.watch(appLocaleProvider);
    return MaterialApp(
      locale: overrideCode == null ? null : Locale(overrideCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: (deviceLocales, _) {
        return AppLocales.resolve(
          overrideCode: overrideCode,
          deviceLocales: deviceLocales ?? const <Locale>[],
        );
      },
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final code = Localizations.localeOf(context).languageCode;
          return Scaffold(
            body: ListTile(
              title: Text(l10n.language),
              subtitle: Text(AppLocales.displayName(l10n, code)),
              onTap: () => showLanguagePickerSheet(context),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('cambiar idioma en el picker actualiza el subtítulo', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('es');
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeStoreProvider.overrideWithValue(MemoryLocaleStore('es')),
        ],
        child: const _SettingsLanguageHarness(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);

    await tester.tap(find.text('Idioma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Idioma'), findsNothing);
  });
}
