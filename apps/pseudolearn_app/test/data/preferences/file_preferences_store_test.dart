import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/data/preferences/file_preferences_store.dart';
import 'package:pseudolearn_app/domain/model/settings/account_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/device_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

void main() {
  group('FilePreferencesStore Tests (CIM-F4)', () {
    late Directory tempDir;
    late FilePreferencesStore store;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('pref_test_');
      store = FilePreferencesStore(directory: tempDir);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Read returns default preferences when file does not exist', () async {
      final prefs = await store.read();
      expect(prefs, const AppPreferences.defaults());
      expect(prefs.language, UiLanguageId.system);
      expect(prefs.isDarkMode, isFalse);
      expect(prefs.editorFontSize, 14.0);
      expect(prefs.assistedDiagramZoom, isTrue);
    });

    test('Read keeps assisted diagram zoom on when the file predates the key',
        () async {
      final file = File(p.join(tempDir.path, 'preferences.json'));
      file.writeAsStringSync('{"language": "english", "themeMode": "dark"}');

      final prefs = await store.read();

      expect(prefs.assistedDiagramZoom, isTrue);
      expect(prefs.language, UiLanguageId.english);
    });

    test('Write persists preferences and read retrieves them', () async {
      const customPrefs = AppPreferences(
        account: AccountPreferences(
          language: UiLanguageId.english,
          themeMode: AppThemeMode.dark,
          assistedDiagramZoom: false,
        ),
        device: DevicePreferences(
          editorFontSize: 18.0,
          showLineNumbers: false,
          showIndentGuides: true,
          hasSeenOnboarding: false,
        ),
      );

      await store.write(customPrefs);
      final loaded = await store.read();

      expect(loaded, equals(customPrefs));
      expect(loaded.language, UiLanguageId.english);
      expect(loaded.isDarkMode, isTrue);
      expect(loaded.editorFontSize, 18.0);
      expect(loaded.showLineNumbers, isFalse);
      expect(loaded.assistedDiagramZoom, isFalse);
    });

    test('Read returns default preferences when file is corrupted', () async {
      final file = File(p.join(tempDir.path, 'preferences.json'));
      file.writeAsStringSync('{ invalid json ::: corrupt');

      final prefs = await store.read();
      expect(prefs, const AppPreferences.defaults());
    });

    test('Read returns default preferences when file contains non-map json', () async {
      final file = File(p.join(tempDir.path, 'preferences.json'));
      file.writeAsStringSync('["array", "instead", "of", "map"]');

      final prefs = await store.read();
      expect(prefs, const AppPreferences.defaults());
    });

    test('Read returns default preferences when file is empty', () async {
      final file = File(p.join(tempDir.path, 'preferences.json'));
      file.writeAsStringSync('   ');

      final prefs = await store.read();
      expect(prefs, const AppPreferences.defaults());
    });
  });
}
