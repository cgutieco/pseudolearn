import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/in_memory_preferences_store.dart';

void main() {
  group('SettingsCubit Tests', () {
    late InMemoryPreferencesStore preferences;
    late SettingsCubit cubit;

    setUp(() {
      preferences = InMemoryPreferencesStore();
      cubit = SettingsCubit(
        preferences: preferences,
      );
    });

    test('init loads language, themeMode and diagram assistance preferences',
        () async {
      await preferences.write(const AppPreferences.defaults().copyWith(
        language: UiLanguageId.english,
        themeMode: AppThemeMode.dark,
        assistedDiagramZoom: false,
      ));

      await cubit.init();

      expect(cubit.state.language, equals(UiLanguageId.english));
      expect(cubit.state.themeMode, equals(AppThemeMode.dark));
      expect(cubit.state.assistedDiagramZoom, isFalse);
    });

    test('the diagram assistance starts on before anything is read', () {
      expect(cubit.state.assistedDiagramZoom, isTrue);
    });

    test('setLanguage persists to preferences store and updates state', () async {
      await cubit.setLanguage(UiLanguageId.english);

      expect(cubit.state.language, equals(UiLanguageId.english));
      final savedPrefs = await preferences.read();
      expect(savedPrefs.language, equals(UiLanguageId.english));
    });

    test('setThemeMode persists to preferences store and updates state', () async {
      await cubit.setThemeMode(AppThemeMode.dark);

      expect(cubit.state.themeMode, equals(AppThemeMode.dark));
      final savedPrefs = await preferences.read();
      expect(savedPrefs.themeMode, equals(AppThemeMode.dark));
    });

    test('setAssistedDiagramZoom persists the refusal and updates state',
        () async {
      await cubit.setAssistedDiagramZoom(false);

      expect(cubit.state.assistedDiagramZoom, isFalse);
      final savedPrefs = await preferences.read();
      expect(savedPrefs.assistedDiagramZoom, isFalse);
    });

    test('setAssistedDiagramZoom persists turning the assistance back on',
        () async {
      await cubit.setAssistedDiagramZoom(false);
      await cubit.setAssistedDiagramZoom(true);

      expect(cubit.state.assistedDiagramZoom, isTrue);
      final savedPrefs = await preferences.read();
      expect(savedPrefs.assistedDiagramZoom, isTrue);
    });
  });
}
