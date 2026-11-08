import '../../../domain/model/settings/app_preferences.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/preferences_store.dart';
import '../preference_updates.dart';

final class SetInterfaceLanguage {
  final PreferencesStore _preferences;
  final PreferenceUpdates _updates;

  const SetInterfaceLanguage({
    required PreferencesStore preferences,
    required PreferenceUpdates updates,
  }) : _preferences = preferences,
       _updates = updates;

  Future<AppPreferences> call(UiLanguageId language) async {
    final updated = (await _preferences.read()).copyWith(language: language);
    await _preferences.write(updated);
    _updates.publish(updated);
    return updated;
  }
}
