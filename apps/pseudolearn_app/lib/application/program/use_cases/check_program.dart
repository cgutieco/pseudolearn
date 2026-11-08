import '../../../domain/model/analysis/analysis_report.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/program_analyzer.dart';

final class CheckProgram {
  final ProgramAnalyzer _analyzer;

  const CheckProgram({required ProgramAnalyzer analyzer}) : _analyzer = analyzer;

  AnalysisReport call({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) => _analyzer.analyze(
    sourceCode: sourceCode,
    profileId: profileId,
    languageId: languageId,
  );
}
