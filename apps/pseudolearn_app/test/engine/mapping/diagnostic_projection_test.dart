import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/engine/mapping/diagnostic_projection.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

void main() {
  group('DiagnosticProjection', () {
    test('projects core Diagnostic to AppDiagnostic', () {
      const profile = ClassicSpanishProfile.flexible();
      const renderer = DiagnosticRenderer(
        locale: DiagnosticLocale.es,
        syntaxLexicon: profile,
      );

      final span = Span(
        start: const Position(offset: 0, line: 1, column: 1),
        end: const Position(offset: 5, line: 1, column: 6),
      );
      final coreDiagnostic = Diagnostic(
        code: DiagnosticCode.unclosedAlgorithm,
        severity: Severity.error,
        span: span,
        arguments: const {},
      );

      final appDiagnostic = DiagnosticProjection.toAppDiagnostic(
        coreDiagnostic,
        renderer,
      );

      expect(appDiagnostic.code, 'unclosedAlgorithm');
      expect(appDiagnostic.severity, AppSeverity.error);
      expect(appDiagnostic.primaryRange.startLine, 1);
      expect(appDiagnostic.primaryRange.startColumn, 1);
      expect(appDiagnostic.message, isNotEmpty);
    });
  });
}
