import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Strict vs Flexible Rigor Policies', () {
    test('same undeclared variable program under strict (error) vs flexible (executes)', () {
      const sourceStrict = '''
Proceso TestUndeclared
  total <- 100;
  Escribir "Total: ", total;
FinProceso
''';

      const sourceFlexible = '''
Algoritmo TestUndeclared
  total <- 100
  Escribir "Total: ", total
FinAlgoritmo
''';

      final strictResult = runPipeline(
        sourceStrict,
        profile: const ClassicSpanishProfile.strict(),
      );

      expect(strictResult.hasErrors, isTrue);
      expect(
        strictResult.resolutionResult?.diagnostics.any(
          (d) =>
              d.code == DiagnosticCode.undeclaredVariable &&
              d.severity == Severity.error,
        ),
        isTrue,
      );
      expect(strictResult.typeCheckResult, isNull);
      expect(strictResult.executionResult, isNull);
      expect(strictResult.output, isEmpty);

      final flexibleResult = runPipeline(
        sourceFlexible,
        profile: const ClassicSpanishProfile.flexible(),
      );

      expect(flexibleResult.hasErrors, isFalse);
      expect(
        flexibleResult.resolutionResult?.diagnostics.any(
          (d) =>
              d.code == DiagnosticCode.undeclaredVariable &&
              d.severity == Severity.warning,
        ),
        isTrue,
      );
      expect(flexibleResult.executionResult, isA<ExecutionReady>());
      expect(flexibleResult.finalOutcome, isA<StepFinished>());
      expect(flexibleResult.output, equals('Total: 100\n'));
    });

    test('same uninitialized variable program under strict (static error) vs flexible (runtime halt)', () {
      const sourceStrict = '''
Proceso TestUninitialized
  Definir a, b Como Entero;
  b <- a + 10;
  Escribir b;
FinProceso
''';

      const sourceFlexible = '''
Algoritmo TestUninitialized
  Definir a, b Como Entero
  b <- a + 10
  Escribir b
FinAlgoritmo
''';

      final strictResult = runPipeline(
        sourceStrict,
        profile: const ClassicSpanishProfile.strict(),
      );

      expect(strictResult.hasErrors, isTrue);
      expect(
        strictResult.typeCheckResult?.diagnostics.any(
          (d) =>
              d.code == DiagnosticCode.variableUsedUninitialized &&
              d.severity == Severity.error,
        ),
        isTrue,
      );
      expect(strictResult.executionResult, isA<ExecutionNotExecutable>());

      final flexibleResult = runPipeline(
        sourceFlexible,
        profile: const ClassicSpanishProfile.flexible(),
      );

      expect(flexibleResult.typeCheckResult?.hasErrors, isFalse);
      expect(flexibleResult.executionResult, isA<ExecutionReady>());
      expect(flexibleResult.finalOutcome, isA<StepHalted>());
      expect(
        flexibleResult.runResult?.haltDiagnostic.code,
        equals(DiagnosticCode.uninitializedVariableRead),
      );
    });
  });
}
