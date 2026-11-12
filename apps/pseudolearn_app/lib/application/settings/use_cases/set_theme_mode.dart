import '../../../domain/model/settings/app_preferences.dart';
import '../../../domain/model/settings/app_theme_mode.dart';
import '../../../domain/ports/preferences_store.dart';
import '../preference_updates.dart';

final class SetThemeMode {
  final PreferencesStore _preferences;
  final PreferenceUpdates _updates;

  const SetThemeMode({
    required this._preferences,
    required this._updates,
  });

  Future<AppPreferences> call(AppThemeMode mode) async {
    final updated = (await _preferences.read()).copyWith(themeMode: mode);
    await _preferences.write(updated);
    _updates.publish(updated);
    return updated;
  }
}
