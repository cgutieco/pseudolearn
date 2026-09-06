import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';

final class RuntimeDiagnosticFactory {
  final Severity Function(DiagnosticCode code) severityFor;

  const RuntimeDiagnosticFactory(this.severityFor);

  Diagnostic build(
    DiagnosticCode code,
    Span span, {
    Map<String, DiagnosticArgument> arguments = const {},
    List<Span> relatedSpans = const [],
  }) =>
      Diagnostic(
        code: code,
        severity: severityFor(code),
        span: span,
        arguments: arguments,
        relatedSpans: relatedSpans,
      );
}
