import 'package:doxan/core/data/user_settings_repository.dart';
import 'package:doxan/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._settings);

  final UserSettingsRepository _settings;

  @override
  Future<void> setCompressionProfile(String profile) async {
    final current = await _settings.load();
    await _settings.save(current.copyWith(compressionProfile: profile));
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(userSettingsRepositoryProvider));
});
