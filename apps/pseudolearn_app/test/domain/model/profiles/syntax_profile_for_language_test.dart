import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_for_language.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

void main() {
  group('Syntax Profile For Language', () {
    test('maps english to english syntax profile', () {
      expect(syntaxProfileForLanguage(UiLanguageId.english), SyntaxProfileId.english);
    });

    test('maps spanish and other settings to classic spanish profile', () {
      expect(syntaxProfileForLanguage(UiLanguageId.spanish), SyntaxProfileId.classicSpanish);
      expect(syntaxProfileForLanguage(UiLanguageId.system), SyntaxProfileId.classicSpanish);
    });
  });
}
