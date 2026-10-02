import 'package:docxan/core/locale/app_locale_store.dart';
import 'package:docxan/core/locale/app_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLocaleController extends Notifier<String?> {
  var _alive = true;

  @override
  String? build() {
    _alive = true;
    ref.onDispose(() => _alive = false);
    Future<void>.microtask(_hydrate);
    return null;
  }

  Future<void> _hydrate() async {
    try {
      final saved = await ref.read(localeStoreProvider).load();
      if (!_alive) return;
      if (saved != null && AppLocales.isSupported(saved)) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> setLocale(String code) async {
    if (!AppLocales.isSupported(code)) return;
    state = code;
    await ref.read(localeStoreProvider).save(code);
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleController, String?>(
  AppLocaleController.new,
);
