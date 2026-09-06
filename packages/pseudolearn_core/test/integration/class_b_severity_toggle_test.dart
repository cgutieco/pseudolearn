import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Class B Diagnostic Severity Toggle', () {
    test('undeclaredVariable changes severity only (error vs warning), keeping code, span and args identical', () {
      const source = '''
Proceso TestRigorB;
  contador <- 42;
  Escribir contador;
FinProceso
''';

      final strictResult = runPipeline(
        source,
        profile: const ClassicSpanishProfile.strict(),
      );

      final flexibleResult = runPipeline(
        source,
        profile: const ClassicSpanishProfile.flexible(),
      );

      final strictDiag = strictResult.resolutionResult!.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );
      final flexibleDiag =
          flexibleResult.resolutionResult!.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );

      expect(strictDiag.code, equals(flexibleDiag.code));
      expect(strictDiag.span, equals(flexibleDiag.span));
      expect(strictDiag.arguments.keys, equals(flexibleDiag.arguments.keys));
      expect(
        (strictDiag.arguments['lexeme'] as LexemeDiagnosticArgument).lexeme,
        equals(
          (flexibleDiag.arguments['lexeme'] as LexemeDiagnosticArgument).lexeme,
        ),
      );

      expect(strictDiag.severity, equals(Severity.error));
      expect(flexibleDiag.severity, equals(Severity.warning));
    });

    test('English profile exhibits identical severity toggle for undeclared variables', () {
      const source = '''
Algorithm TestEnglishB;
  counter <- 99;
  Write counter;
EndAlgorithm
''';

      final strictResult = runPipeline(
        source,
        profile: const EnglishProfile.strict(),
      );

      final flexibleResult = runPipeline(
        source,
        profile: const EnglishProfile.flexible(),
      );

      final strictDiag = strictResult.resolutionResult!.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );
      final flexibleDiag =
          flexibleResult.resolutionResult!.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.undeclaredVariable,
      );

      expect(strictDiag.code, equals(DiagnosticCode.undeclaredVariable));
      expect(flexibleDiag.code, equals(DiagnosticCode.undeclaredVariable));
      expect(strictDiag.severity, equals(Severity.error));
      expect(flexibleDiag.severity, equals(Severity.warning));
    });
  });
}
