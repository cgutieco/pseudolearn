import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/mapping/profile_catalog.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

void main() {
  group('ProfileCatalog', () {
    test('maps syntax profiles correctly', () {
      final classic = ProfileCatalog.toLanguageProfile(SyntaxProfileId.classicSpanish);
      expect(classic, isA<ClassicSpanishProfile>());

      final english = ProfileCatalog.toLanguageProfile(SyntaxProfileId.english);
      expect(english, isA<EnglishProfile>());
    });

    test('maps ui language to diagnostic locale', () {
      expect(
        ProfileCatalog.toDiagnosticLocale(UiLanguageId.spanish),
        DiagnosticLocale.es,
      );
      expect(
        ProfileCatalog.toDiagnosticLocale(UiLanguageId.english),
        DiagnosticLocale.en,
      );
      expect(
        ProfileCatalog.toDiagnosticLocale(UiLanguageId.system),
        DiagnosticLocale.es,
      );
    });
  });
}
