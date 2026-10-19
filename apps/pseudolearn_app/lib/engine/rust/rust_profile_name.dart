import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';

String rustProfileName(SyntaxProfileId profileId) => switch (profileId) {
  SyntaxProfileId.classicSpanish => 'es',
  SyntaxProfileId.english => 'en',
};

String? rustLocaleName(UiLanguageId languageId) => switch (languageId) {
  UiLanguageId.spanish => 'es',
  UiLanguageId.english => 'en',
  UiLanguageId.system => null,
};

const String rustStrictness = 'flexible';
