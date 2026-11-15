import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/ports/preferences_store.dart';

final class InMemoryPreferencesStore implements PreferencesStore {
  AppPreferences _preferences;

  InMemoryPreferencesStore([AppPreferences? initial])
      : _preferences = initial ?? const AppPreferences.defaults();

  @override
  Future<AppPreferences> read() async => _preferences;

  @override
  Future<void> write(AppPreferences preferences) async {
    _preferences = preferences;
  }
}
