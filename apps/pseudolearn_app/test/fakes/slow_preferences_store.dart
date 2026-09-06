import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/ports/preferences_store.dart';

final class SlowPreferencesStore implements PreferencesStore {
  AppPreferences _preferences;
  final Duration delay;

  SlowPreferencesStore(this._preferences, {this.delay = const Duration(milliseconds: 20)});

  @override
  Future<AppPreferences> read() async {
    await Future<void>.delayed(delay);
    return _preferences;
  }

  @override
  Future<void> write(AppPreferences preferences) async {
    _preferences = preferences;
  }
}
