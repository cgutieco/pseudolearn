import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/account_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

void main() {
  group('AccountPreferences', () {
    test('defaults have expected initial values', () {
      const prefs = AccountPreferences.defaults();
      expect(prefs.language, equals(UiLanguageId.system));
      expect(prefs.themeMode, equals(AppThemeMode.system));
      expect(prefs.assistedDiagramZoom, isTrue);
      expect(prefs.isDarkMode, isFalse);
    });

    test('isDarkMode returns true only when themeMode is dark', () {
      const darkPrefs = AccountPreferences(
        language: UiLanguageId.spanish,
        themeMode: AppThemeMode.dark,
        assistedDiagramZoom: false,
      );
      expect(darkPrefs.isDarkMode, isTrue);

      const lightPrefs = AccountPreferences(
        language: UiLanguageId.spanish,
        themeMode: AppThemeMode.light,
        assistedDiagramZoom: false,
      );
      expect(lightPrefs.isDarkMode, isFalse);
    });

    test('copyWith updates selected fields correctly', () {
      const initial = AccountPreferences.defaults();
      final updated = initial.copyWith(
        language: UiLanguageId.english,
        assistedDiagramZoom: false,
      );
      expect(updated.language, equals(UiLanguageId.english));
      expect(updated.themeMode, equals(AppThemeMode.system));
      expect(updated.assistedDiagramZoom, isFalse);
    });

    test('copyWith handles isDarkMode boolean flag', () {
      const initial = AccountPreferences.defaults();
      final dark = initial.copyWith(isDarkMode: true);
      expect(dark.themeMode, equals(AppThemeMode.dark));

      final light = initial.copyWith(isDarkMode: false);
      expect(light.themeMode, equals(AppThemeMode.light));
    });

    test('serializes and deserializes cleanly via JSON', () {
      const original = AccountPreferences(
        language: UiLanguageId.english,
        themeMode: AppThemeMode.dark,
        assistedDiagramZoom: false,
      );
      final json = original.toJson();
      final restored = AccountPreferences.fromJson(json);

      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test('fromJson falls back to defaults for missing or invalid values', () {
      final restored = AccountPreferences.fromJson(const {});
      expect(restored.language, equals(UiLanguageId.system));
      expect(restored.themeMode, equals(AppThemeMode.system));
      expect(restored.assistedDiagramZoom, isTrue);
    });

    test('equality compares structural field values', () {
      const a = AccountPreferences(
        language: UiLanguageId.spanish,
        themeMode: AppThemeMode.light,
        assistedDiagramZoom: true,
      );
      const b = AccountPreferences(
        language: UiLanguageId.spanish,
        themeMode: AppThemeMode.light,
        assistedDiagramZoom: true,
      );
      const c = AccountPreferences(
        language: UiLanguageId.spanish,
        themeMode: AppThemeMode.dark,
        assistedDiagramZoom: true,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
