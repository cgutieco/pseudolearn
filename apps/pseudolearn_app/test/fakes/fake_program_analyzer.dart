import 'package:pseudolearn_app/domain/model/analysis/analysis_report.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/program_analyzer.dart';

final class FakeProgramAnalyzer implements ProgramAnalyzer {
  final List<String> analyzedSources = [];
  final List<SyntaxProfileId> analyzedProfiles = [];

  @override
  AnalysisReport analyze({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    analyzedSources.add(sourceCode);
    analyzedProfiles.add(profileId);
    return AnalysisReport(
      isExecutable: true,
      diagnostics: const [],
      highlightSpans: [
        HighlightSpan(
          range: SourceRange(
            startOffset: 0,
            endOffset: sourceCode.length,
            startLine: 1,
            startColumn: 1,
            endLine: 1,
            endColumn: sourceCode.length + 1,
          ),
          category: HighlightCategory.keywordStructured,
        ),
      ],
    );
  }
}
