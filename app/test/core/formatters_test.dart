import 'package:docxan/app/l10n/app_localizations_en.dart';
import 'package:docxan/app/l10n/app_localizations_es.dart';
import 'package:docxan/app/l10n/app_localizations_fr.dart';
import 'package:docxan/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatBytes usa KB para páginas típicas', () {
    expect(formatBytes(312 * 1024), '312 KB');
  });

  test('formatRelativeTime distingue horas y ayer', () {
    final l10n = AppLocalizationsEs();
    final now = DateTime(2026, 9, 20, 14);
    expect(
      formatRelativeTime(
        now.subtract(const Duration(hours: 2)),
        now: now,
        l10n: l10n,
      ),
      'Hace 2 h',
    );
    expect(
      formatRelativeTime(
        now.subtract(const Duration(hours: 26)),
        now: now,
        l10n: l10n,
      ),
      'Ayer',
    );
  });

  test('formatRelativeTime usa inglés y francés', () {
    final now = DateTime(2026, 9, 20, 14);
    final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
    expect(
      formatRelativeTime(fiveMinutesAgo, now: now, l10n: AppLocalizationsEn()),
      '5 min ago',
    );
    expect(
      formatRelativeTime(fiveMinutesAgo, now: now, l10n: AppLocalizationsFr()),
      'Il y a 5 min',
    );
    expect(
      formatRelativeTime(now, now: now, l10n: AppLocalizationsEn()),
      'Now',
    );
  });
}
