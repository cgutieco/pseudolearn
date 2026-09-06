import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/analysis_report.dart';
import '../../domain/model/analysis/highlight_span.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_analyzer.dart';
import '../mapping/diagnostic_projection.dart';
import '../mapping/profile_catalog.dart';
import '../mapping/span_projection.dart';
import 'analysis_cache.dart';
import 'program_analysis.dart';

final class CoreProgramAnalyzer implements ProgramAnalyzer {
  final AnalysisCache _analyses;

  CoreProgramAnalyzer({AnalysisCache? analyses})
      : _analyses = analyses ?? AnalysisCache();

  @override
  AnalysisReport analyze({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final analysis = _analyses.of(sourceCode, profileId);
    final renderer = DiagnosticRenderer(
      locale: ProfileCatalog.toDiagnosticLocale(languageId),
      syntaxLexicon: analysis.profile,
    );

    return AnalysisReport(
      isExecutable: analysis.isExecutable,
      diagnostics: analysis.diagnostics
          .map((diagnostic) => DiagnosticProjection.toAppDiagnostic(diagnostic, renderer))
          .toList(),
      highlightSpans: _highlightSpans(analysis),
    );
  }

  List<HighlightSpan> _highlightSpans(ProgramAnalysis analysis) => analysis.tokens
      .map(SpanProjection.toHighlightSpan)
      .whereType<HighlightSpan>()
      .toList();
}
