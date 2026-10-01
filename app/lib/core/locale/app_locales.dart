import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

abstract final class AppLocales {
  static const fallback = 'es';
  static const codes = <String>['es', 'en', 'fr'];
  static const supported = <String>{'es', 'en', 'fr'};

  static bool isSupported(String code) => supported.contains(code);

  static String resolveLanguageCode(Iterable<Locale> deviceLocales) {
    for (final locale in deviceLocales) {
      final code = locale.languageCode.toLowerCase();
      if (isSupported(code)) return code;
    }
    return fallback;
  }

  static Locale resolve({
    required String? overrideCode,
    required Iterable<Locale> deviceLocales,
  }) {
    if (overrideCode != null && isSupported(overrideCode)) {
      return Locale(overrideCode);
    }
    return Locale(resolveLanguageCode(deviceLocales));
  }

  static String displayName(AppLocalizations l10n, String code) {
    return switch (code) {
      'en' => l10n.english,
      'fr' => l10n.french,
      _ => l10n.spanish,
    };
  }
}
