import 'package:docxan/core/locale/app_locales.dart';
import 'package:docxan/features/settings/presentation/pages/legal_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resuelve es, en y fr desde el dispositivo', () {
    expect(
      AppLocales.resolveLanguageCode(const [Locale('fr', 'CA')]),
      'fr',
    );
    expect(
      AppLocales.resolveLanguageCode(const [Locale('en', 'US')]),
      'en',
    );
    expect(
      AppLocales.resolveLanguageCode(const [Locale('es', 'MX')]),
      'es',
    );
  });

  test('el idioma del dispositivo no soportado cae a español', () {
    expect(
      AppLocales.resolveLanguageCode(const [Locale('de'), Locale('it')]),
      'es',
    );
  });

  test('el override guardado gana al idioma del dispositivo', () {
    expect(
      AppLocales.resolve(
        overrideCode: 'en',
        deviceLocales: const [Locale('fr')],
      ),
      const Locale('en'),
    );
    expect(
      AppLocales.resolve(
        overrideCode: null,
        deviceLocales: const [Locale('fr')],
      ),
      const Locale('fr'),
    );
  });

  test('elige el markdown legal según el idioma', () {
    expect(
      legalMarkdownAsset(kind: 'privacy', languageCode: 'en'),
      'assets/legal/privacy_en.md',
    );
    expect(
      legalMarkdownAsset(kind: 'terms', languageCode: 'fr'),
      'assets/legal/terms_fr.md',
    );
    expect(
      legalMarkdownAsset(kind: 'privacy', languageCode: 'es'),
      'assets/legal/privacy.md',
    );
  });
}
