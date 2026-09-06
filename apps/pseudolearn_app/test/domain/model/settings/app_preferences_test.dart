import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/account_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/device_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

void main() {
  group('AppPreferences', () {
    test('defaults initialize both account and device preferences to defaults', () {
      const prefs = AppPreferences.defaults();
      expect(prefs.account, equals(const AccountPreferences.defaults()));
      expect(prefs.device, equals(const DevicePreferences.defaults()));
      expect(prefs.language, equals(UiLanguageId.system));
      expect(prefs.themeMode, equals(AppThemeMode.system));
      expect(prefs.isDarkMode, isFalse);
      expect(prefs.assistedDiagramZoom, isTrue);
      expect(prefs.editorFontSize, equals(14.0));
      expect(prefs.showLineNumbers, isTrue);
      expect(prefs.showIndentGuides, isTrue);
      expect(prefs.hasSeenOnboarding, isFalse);
    });

    test('copyWith updates individual fields while maintaining separation', () {
      const initial = AppPreferences.defaults();
      final updated = initial.copyWith(
        language: UiLanguageId.english,
        editorFontSize: 16.0,
      );

      expect(updated.language, equals(UiLanguageId.english));
      expect(updated.account.language, equals(UiLanguageId.english));
      expect(updated.editorFontSize, equals(16.0));
      expect(updated.device.editorFontSize, equals(16.0));
      expect(updated.assistedDiagramZoom, isTrue);
    });

    test('fromJson deserializes legacy flat json for backward compatibility', () {
      final legacyJson = {
        'language': 'english',
        'themeMode': 'dark',
        'editorFontSize': 18.0,
        'showLineNumbers': false,
        'showIndentGuides': true,
        'assistedDiagramZoom': false,
        'hasSeenOnboarding': true,
      };

      final prefs = AppPreferences.fromJson(legacyJson);
      expect(prefs.language, equals(UiLanguageId.english));
      expect(prefs.themeMode, equals(AppThemeMode.dark));
      expect(prefs.isDarkMode, isTrue);
      expect(prefs.editorFontSize, equals(18.0));
      expect(prefs.showLineNumbers, isFalse);
      expect(prefs.showIndentGuides, isTrue);
      expect(prefs.assistedDiagramZoom, isFalse);
      expect(prefs.hasSeenOnboarding, isTrue);
    });

    test('fromJson deserializes partitioned nested json structure', () {
      final partitionedJson = {
        'account': {
          'language': 'spanish',
          'themeMode': 'light',
          'assistedDiagramZoom': true,
        },
        'device': {
          'editorFontSize': 20.0,
          'showLineNumbers': true,
          'showIndentGuides': false,
          'hasSeenOnboarding': true,
        },
      };

      final prefs = AppPreferences.fromJson(partitionedJson);
      expect(prefs.language, equals(UiLanguageId.spanish));
      expect(prefs.themeMode, equals(AppThemeMode.light));
      expect(prefs.editorFontSize, equals(20.0));
      expect(prefs.showIndentGuides, isFalse);
    });

    test('toJson emits both nested partitioned maps and flat backward-compatible fields', () {
      const prefs = AppPreferences(
        account: AccountPreferences(
          language: UiLanguageId.english,
          themeMode: AppThemeMode.dark,
          assistedDiagramZoom: false,
        ),
        device: DevicePreferences(
          editorFontSize: 16.0,
          showLineNumbers: false,
          showIndentGuides: true,
          hasSeenOnboarding: true,
        ),
      );

      final json = prefs.toJson();
      expect(json['account'], isA<Map<String, dynamic>>());
      expect(json['device'], isA<Map<String, dynamic>>());
      expect(json['language'], equals('english'));
      expect(json['editorFontSize'], equals(16.0));
    });

    test('equality compares structural composition of account and device', () {
      const a = AppPreferences.defaults();
      const b = AppPreferences.defaults();
      final c = a.copyWith(editorFontSize: 18.0);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
