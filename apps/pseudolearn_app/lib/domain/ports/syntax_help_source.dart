import '../model/help/help_query_result.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class SyntaxHelpSource {
  HelpQueryResult query({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required int cursorUtf16,
    required int revision,
  });
}
