import 'package:bloc/bloc.dart';
import '../../domain/model/settings/app_theme_mode.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/preferences_store.dart';
import 'settings_state.dart';

final class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesStore preferences;

  SettingsCubit({
    required this.preferences,
  }) : super(const SettingsState());

  Future<void> init() async {
    final prefs = await preferences.read();
    emit(state.copyWith(
      language: prefs.language,
      themeMode: prefs.themeMode,
      assistedDiagramZoom: prefs.assistedDiagramZoom,
    ));
  }

  Future<void> setLanguage(UiLanguageId language) async {
    final prefs = await preferences.read();
    final updated = prefs.copyWith(language: language);
    await preferences.write(updated);
    emit(state.copyWith(language: language));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await preferences.read();
    final updated = prefs.copyWith(themeMode: mode);
    await preferences.write(updated);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setAssistedDiagramZoom(bool isAssisted) async {
    final prefs = await preferences.read();
    final updated = prefs.copyWith(assistedDiagramZoom: isAssisted);
    await preferences.write(updated);
    emit(state.copyWith(assistedDiagramZoom: isAssisted));
  }
}
