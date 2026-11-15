import '../model/settings/app_preferences.dart';

abstract interface class PreferencesStore {
  Future<AppPreferences> read();
  Future<void> write(AppPreferences preferences);
}
