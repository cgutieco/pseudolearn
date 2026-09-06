import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import 'span_projection.dart';

final class DiagnosticProjection {
  const DiagnosticProjection._();

  static AppDiagnostic toAppDiagnostic(
    Diagnostic diagnostic,
    DiagnosticRenderer renderer,
  ) {
    final message = renderer.render(diagnostic);
    final severity = toAppSeverity(diagnostic.severity);
    final primaryRange = SpanProjection.toSourceRange(diagnostic.span);
    final related = diagnostic.relatedSpans.map((span) {
      final line = span.start.line;
      final col = span.start.column;
      final label = renderer.locale == DiagnosticLocale.es
          ? 'Ubicación relacionada en línea $line, col $col'
          : 'Related location at line $line, col $col';
      return RelatedRange(
        label: label,
        range: SpanProjection.toSourceRange(span),
      );
    }).toList();

    return AppDiagnostic(
      code: diagnostic.code.name,
      message: message,
      severity: severity,
      primaryRange: primaryRange,
      relatedRanges: related,
    );
  }

  static AppSeverity toAppSeverity(Severity severity) {
    return switch (severity) {
      Severity.error => AppSeverity.error,
      Severity.warning => AppSeverity.warning,
      Severity.info => AppSeverity.info,
      Severity.hint => AppSeverity.hint,
    };
  }
}
