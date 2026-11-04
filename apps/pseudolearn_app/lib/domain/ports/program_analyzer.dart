import '../model/analysis/analysis_report.dart';
import '../model/profiles/syntax_profile_id.dart';
import '../model/settings/ui_language_id.dart';

abstract interface class ProgramAnalyzer {
  AnalysisReport analyze({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  });
}
