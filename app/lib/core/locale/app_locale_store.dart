import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/locale/app_locales.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocaleStore {
  Future<String?> load();
  Future<void> save(String code);
}

class MemoryLocaleStore implements LocaleStore {
  MemoryLocaleStore([this.value]);

  String? value;

  @override
  Future<String?> load() async => value;

  @override
  Future<void> save(String code) async {
    value = code;
  }
}

class PrefsLocaleStore implements LocaleStore {
  @override
  Future<String?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(StorageKeys.appLocale);
      if (saved != null && AppLocales.isSupported(saved)) return saved;
    } catch (error) {
      AppLogger.debug('Locale prefs load skipped: $error');
    }
    return null;
  }

  @override
  Future<void> save(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.appLocale, code);
    } catch (error) {
      AppLogger.debug('Locale prefs save skipped: $error');
    }
  }
}

final localeStoreProvider = Provider<LocaleStore>((ref) {
  return PrefsLocaleStore();
});
