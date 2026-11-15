import 'app_diagnostic.dart';
import 'highlight_span.dart';

final class AnalysisReport {
  final bool isExecutable;
  final List<AppDiagnostic> diagnostics;
  final List<HighlightSpan> highlightSpans;

  const AnalysisReport({
    required this.isExecutable,
    required this.diagnostics,
    required this.highlightSpans,
  });

  const AnalysisReport.empty()
      : isExecutable = true,
        diagnostics = const [],
        highlightSpans = const [];

  bool get hasErrors {
    return diagnostics.any((diagnostic) => diagnostic.severity == AppSeverity.error);
  }
}
