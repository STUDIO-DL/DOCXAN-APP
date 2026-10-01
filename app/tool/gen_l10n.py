"""Generate Flutter-style gen-l10n Dart files from ARB sources."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARB_DIR = ROOT / "l10n"
OUT_DIR = ROOT / "lib" / "app" / "l10n"

PLURAL_RE = re.compile(r"^\{(\w+),\s*plural,\s*(.+)\}$", re.DOTALL)
PLACEHOLDER_RE = re.compile(r"\{(\w+)\}")
PLURAL_PART_RE = re.compile(r"(=0|zero|one|two|few|many|other)\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}")

LOCALE_NAMES = {
    "es": ("Spanish Castilian", "es"),
    "en": ("English", "en"),
    "fr": ("French", "fr"),
}


def load_arb(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    return json.loads(text)


def dart_string(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
    )
    if "\n" in escaped:
        return "'''" + escaped.replace("'''", "\\'''") + "'''"
    return "'" + escaped + "'"


def interpolate(template: str) -> str:
    def repl(match: re.Match[str]) -> str:
        return "$" + match.group(1)

    return PLACEHOLDER_RE.sub(repl, template)


def dart_interpolated(template: str) -> str:
    interpolated = interpolate(template)
    escaped = interpolated.replace("\\", "\\\\").replace("'", "\\'")
    # Keep $name interpolations; escape stray $.
    escaped = re.sub(r"\$(?!\{|\w)", r"\\$", escaped)
    if "\n" in escaped:
        return '"""' + escaped + '"""'
    return "'" + escaped + "'"


def message_keys(template: dict) -> list[str]:
    keys = []
    for key in template:
        if key.startswith("@") or key.startswith("@@"):
            continue
        keys.append(key)
    return keys


def placeholder_meta(template: dict, key: str) -> dict:
    meta = template.get(f"@{key}") or {}
    return meta.get("placeholders") or {}


def signature(key: str, placeholders: dict) -> str:
    if not placeholders:
        return f"String get {key}"
    params = []
    for name, info in placeholders.items():
        dart_type = info.get("type", "String")
        params.append(f"{dart_type} {name}")
    return f"String {key}({', '.join(params)})"


def parse_plural(template: str) -> tuple[str, dict[str, str]] | None:
    match = PLURAL_RE.match(template.strip())
    if not match:
        return None
    name = match.group(1)
    body = match.group(2)
    parts: dict[str, str] = {}
    for part in PLURAL_PART_RE.finditer(body):
        label = part.group(1)
        text = part.group(2)
        if label == "=0":
            label = "zero"
        parts[label] = text
    return name, parts


def impl_body(key: str, value: str, placeholders: dict) -> str:
    plural = parse_plural(value)
    if plural:
        name, parts = plural
        lines = [
            f"  @override",
            f"  String {key}(int {name}) {{",
            f"    String _temp0 = intl.Intl.pluralLogic(",
            f"      {name},",
            f"      locale: localeName,",
        ]
        for label in ("other", "one", "zero", "two", "few", "many"):
            if label in parts:
                lines.append(f"      {label}: {dart_interpolated(parts[label])},")
        lines.extend(
            [
                "    );",
                "    return '$_temp0';",
                "  }",
            ]
        )
        return "\n".join(lines)

    if placeholders:
        params = ", ".join(
            f"{info.get('type', 'String')} {name}" for name, info in placeholders.items()
        )
        return (
            f"  @override\n"
            f"  String {key}({params}) {{\n"
            f"    return {dart_interpolated(value)};\n"
            f"  }}"
        )

    return f"  @override\n  String get {key} => {dart_string(value)};"


def generate_locale_file(locale: str, messages: dict, template: dict, keys: list[str]) -> str:
    title, code = LOCALE_NAMES[locale]
    class_name = f"AppLocalizations{locale.capitalize()}"
    lines = [
        "// ignore: unused_import",
        "import 'package:intl/intl.dart' as intl;",
        "import 'app_localizations.dart';",
        "",
        "// ignore_for_file: type=lint",
        "",
        f"/// The translations for {title} (`{code}`).",
        f"class {class_name} extends AppLocalizations {{",
        f"  {class_name}([String locale = '{code}']) : super(locale);",
        "",
    ]
    for key in keys:
        placeholders = placeholder_meta(template, key)
        value = messages.get(key)
        if value is None:
            raise SystemExit(f"Missing key {key} in {locale}")
        lines.append(impl_body(key, value, placeholders))
        lines.append("")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def generate_abstract(template: dict, keys: list[str]) -> str:
    header = '''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];
'''
    lines = [header.rstrip()]
    for key in keys:
        placeholders = placeholder_meta(template, key)
        sample = template[key]
        escaped_sample = sample.replace("\\", "\\\\")
        lines.append("")
        lines.append(f"  /// No description provided for @{key}.")
        lines.append("  ///")
        lines.append("  /// In es, this message translates to:")
        lines.append(f"  /// **'{escaped_sample}'**")
        lines.append(f"  {signature(key, placeholders)};")
    lines.append("}")
    lines.append("")
    lines.append(
        """
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
""".strip()
    )
    lines.append("")
    return "\n".join(lines) + "\n"


def main() -> None:
    template = load_arb(ARB_DIR / "app_es.arb")
    keys = message_keys(template)
    locales = {
        "es": template,
        "en": load_arb(ARB_DIR / "app_en.arb"),
        "fr": load_arb(ARB_DIR / "app_fr.arb"),
    }
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "app_localizations.dart").write_text(
        generate_abstract(template, keys), encoding="utf-8"
    )
    for locale, messages in locales.items():
        path = OUT_DIR / f"app_localizations_{locale}.dart"
        path.write_text(
            generate_locale_file(locale, messages, template, keys), encoding="utf-8"
        )
        print(f"wrote {path}")
    print(f"keys={len(keys)}")


if __name__ == "__main__":
    main()
