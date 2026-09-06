import 'app_theme_mode.dart';
import 'ui_language_id.dart';

final class AccountPreferences {
  final UiLanguageId language;
  final AppThemeMode themeMode;
  final bool assistedDiagramZoom;

  bool get isDarkMode => themeMode == AppThemeMode.dark;

  const AccountPreferences({
    required this.language,
    required this.themeMode,
    required this.assistedDiagramZoom,
  });

  const AccountPreferences.defaults()
      : language = UiLanguageId.system,
        themeMode = AppThemeMode.system,
        assistedDiagramZoom = true;

  AccountPreferences copyWith({
    UiLanguageId? language,
    AppThemeMode? themeMode,
    bool? isDarkMode,
    bool? assistedDiagramZoom,
  }) {
    final effectiveTheme = themeMode ??
        (isDarkMode != null
            ? (isDarkMode ? AppThemeMode.dark : AppThemeMode.light)
            : this.themeMode);
    return AccountPreferences(
      language: language ?? this.language,
      themeMode: effectiveTheme,
      assistedDiagramZoom: assistedDiagramZoom ?? this.assistedDiagramZoom,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language.name,
        'themeMode': themeMode.name,
        'assistedDiagramZoom': assistedDiagramZoom,
      };

  factory AccountPreferences.fromJson(Map<String, dynamic> json) {
    final langStr = json['language'] as String?;
    final language = UiLanguageId.values.firstWhere(
      (v) => v.name == langStr,
      orElse: () => UiLanguageId.system,
    );

    final themeStr = json['themeMode'] as String?;
    final themeMode = AppThemeMode.values.firstWhere(
      (v) => v.name == themeStr,
      orElse: () => (json['isDarkMode'] as bool? ?? false)
          ? AppThemeMode.dark
          : AppThemeMode.system,
    );

    return AccountPreferences(
      language: language,
      themeMode: themeMode,
      assistedDiagramZoom: json['assistedDiagramZoom'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountPreferences &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          themeMode == other.themeMode &&
          assistedDiagramZoom == other.assistedDiagramZoom;

  @override
  int get hashCode => Object.hash(
        language,
        themeMode,
        assistedDiagramZoom,
      );
}
