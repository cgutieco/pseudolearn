import 'package:bloc/bloc.dart';
import '../../domain/model/settings/app_theme_mode.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/preferences_store.dart';
import 'preference_update_follower.dart';
import 'preference_updates.dart';
import 'settings_state.dart';
import 'use_cases/set_interface_language.dart';
import 'use_cases/set_theme_mode.dart';

final class SettingsCubit extends Cubit<SettingsState>
    with PreferenceUpdateFollower<SettingsState> {
  final PreferencesStore preferences;
  final SetThemeMode _setThemeMode;
  final SetInterfaceLanguage _setLanguage;

  SettingsCubit({
    required PreferencesStore preferences,
    PreferenceUpdates? updates,
  }) : this._withUpdates(preferences, updates ?? PreferenceUpdates());

  SettingsCubit._withUpdates(this.preferences, PreferenceUpdates updates)
    : _setThemeMode = SetThemeMode(preferences: preferences, updates: updates),
      _setLanguage = SetInterfaceLanguage(preferences: preferences, updates: updates),
      super(const SettingsState()) {
    followPreferenceUpdates(updates.stream, (prefs) {
      emit(state.copyWith(language: prefs.language, themeMode: prefs.themeMode));
    });
  }

  Future<void> init() async {
    final prefs = await preferences.read();
    emit(state.copyWith(
      language: prefs.language,
      themeMode: prefs.themeMode,
      assistedDiagramZoom: prefs.assistedDiagramZoom,
      editorAssistance: prefs.editorAssistance,
    ));
  }

  Future<void> setLanguage(UiLanguageId language) async {
    await _setLanguage(language);
    emit(state.copyWith(language: language));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setAssistedDiagramZoom(bool isAssisted) async {
    final prefs = await preferences.read();
    final updated = prefs.copyWith(assistedDiagramZoom: isAssisted);
    await preferences.write(updated);
    emit(state.copyWith(assistedDiagramZoom: isAssisted));
  }

  Future<void> setEditorAssistance(bool isEnabled) async {
    final prefs = await preferences.read();
    final updated = prefs.copyWith(editorAssistance: isEnabled);
    await preferences.write(updated);
    emit(state.copyWith(editorAssistance: isEnabled));
  }
}
