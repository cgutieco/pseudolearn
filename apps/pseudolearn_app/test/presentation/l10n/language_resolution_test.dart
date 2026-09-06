import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('Language Resolution and Localizations Tests (CIM-F3)', () {
    test('Direct language selection resolves correct locale code', () {
      expect(UiLanguageId.spanish.resolveLocaleCode('en'), 'es');
      expect(UiLanguageId.spanish.resolveLocaleCode(null), 'es');
      expect(UiLanguageId.english.resolveLocaleCode('es'), 'en');
      expect(UiLanguageId.english.resolveLocaleCode(null), 'en');
    });

    test('System language selection respects supported system locale', () {
      expect(UiLanguageId.system.resolveLocaleCode('en'), 'en');
      expect(UiLanguageId.system.resolveLocaleCode('es'), 'es');
    });

    test('System language selection falls back to default on unsupported or null locale', () {
      expect(UiLanguageId.system.resolveLocaleCode('fr'), 'es');
      expect(UiLanguageId.system.resolveLocaleCode('de'), 'es');
      expect(UiLanguageId.system.resolveLocaleCode('ja'), 'es');
      expect(UiLanguageId.system.resolveLocaleCode(null), 'es');
      expect(UiLanguageId.system.resolveLocaleCode(''), 'es');
    });

    test('AppLocalizations contains expected supported locales and delegates', () {
      final supportedCodes = AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .toSet();

      expect(supportedCodes, contains('es'));
      expect(supportedCodes, contains('en'));
      expect(AppLocalizations.localizationsDelegates, isNotEmpty);
    });

    test('AppLocalizations lookup retrieves translations cleanly', () {
      final es = lookupAppLocalizations(const Locale('es'));
      final en = lookupAppLocalizations(const Locale('en'));

      expect(es.appTitle, 'PseudoLearn');
      expect(en.appTitle, 'PseudoLearn');
      expect(es.actionSave, 'Guardar');
      expect(en.actionSave, 'Save');
      expect(es.diagnosticsCount(0), 'Sin problemas');
      expect(en.diagnosticsCount(0), 'No issues');
      expect(es.diagnosticsCount(1), '1 problema');
      expect(en.diagnosticsCount(1), '1 issue');
      expect(es.diagnosticsCount(5), '5 problemas');
      expect(en.diagnosticsCount(5), '5 issues');
    });
  });
}
