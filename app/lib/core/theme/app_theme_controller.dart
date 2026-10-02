import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends Notifier<ThemeMode> {
  var _alive = true;

  @override
  ThemeMode build() {
    _alive = true;
    ref.onDispose(() => _alive = false);
    Future<void>.microtask(_hydrate);
    return ThemeMode.light;
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(StorageKeys.appTheme);
      if (!_alive) return;
      if (saved == 'dark') state = ThemeMode.dark;
      if (saved == 'light') state = ThemeMode.light;
    } catch (error) {
      AppLogger.debug('Theme prefs load skipped: $error');
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        StorageKeys.appTheme,
        mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (error) {
      AppLogger.debug('Theme prefs save skipped: $error');
    }
  }
}

final appThemeModeProvider = NotifierProvider<AppThemeController, ThemeMode>(
  AppThemeController.new,
);
