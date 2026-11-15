import '../settings/ui_language_id.dart';
import 'syntax_profile_id.dart';

SyntaxProfileId syntaxProfileForLanguage(UiLanguageId language) {
  return language == UiLanguageId.english
      ? SyntaxProfileId.english
      : SyntaxProfileId.classicSpanish;
}
