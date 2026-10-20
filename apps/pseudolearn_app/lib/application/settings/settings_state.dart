import '../../domain/model/settings/app_theme_mode.dart';
import '../../domain/model/settings/ui_language_id.dart';

final class SettingsState {
  final UiLanguageId language;
  final AppThemeMode themeMode;
  final bool assistedDiagramZoom;
  final bool editorAssistance;

  const SettingsState({
    this.language = UiLanguageId.system,
    this.themeMode = AppThemeMode.system,
    this.assistedDiagramZoom = true,
    this.editorAssistance = false,
  });

  SettingsState copyWith({
    UiLanguageId? language,
    AppThemeMode? themeMode,
    bool? assistedDiagramZoom,
    bool? editorAssistance,
  }) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      assistedDiagramZoom: assistedDiagramZoom ?? this.assistedDiagramZoom,
      editorAssistance: editorAssistance ?? this.editorAssistance,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          themeMode == other.themeMode &&
          assistedDiagramZoom == other.assistedDiagramZoom &&
          editorAssistance == other.editorAssistance;

  @override
  int get hashCode => Object.hash(
        language,
        themeMode,
        assistedDiagramZoom,
        editorAssistance,
      );
}
