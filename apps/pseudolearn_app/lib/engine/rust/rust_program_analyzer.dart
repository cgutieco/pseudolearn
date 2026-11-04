import '../../domain/model/analysis/analysis_report.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_analyzer.dart';
import 'rust_analysis_api.dart';
import 'rust_diagnostic_projection.dart';
import 'rust_profile_name.dart';
import 'rust_syntax_highlighter.dart';
import 'source_offset_index.dart';

final class RustProgramAnalyzer implements ProgramAnalyzer {
  final RustAnalysisApi _api;

  const RustProgramAnalyzer(this._api);

  @override
  AnalysisReport analyze({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final profile = rustProfileName(profileId);
    final handle = _api.open(
      source: sourceCode,
      profile: profile,
      locale: rustLocaleName(languageId),
    );
    try {
      final report = _api.report(handle);
      final offsets = SourceOffsetIndex(sourceCode);
      final projection = RustDiagnosticProjection(offsets, profile);
      final diagnostics = [
        for (final diagnostic in report['diagnostics'] as List<Object?>)
          projection.project(diagnostic as Map<String, Object?>),
      ];
      return AnalysisReport(
        isExecutable:
            report['tree'] as bool &&
            !diagnostics.any((item) => item.severity.name == 'error'),
        diagnostics: diagnostics,
        highlightSpans: RustSyntaxHighlighter(
          offsets,
        ).project(report['tokens'] as List<Object?>? ?? const []),
      );
    } finally {
      _api.release(handle);
    }
  }
}
