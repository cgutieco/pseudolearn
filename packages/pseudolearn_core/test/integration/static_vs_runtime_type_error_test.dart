import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Static Type Checking vs Runtime Errors (Sibling Programs)', () {
    test('Program A fails at static typecheck, Program B fails at runtime (1-line difference)', () {
      const programA = '''
Algoritmo ParHermanos
  Definir total, divisor Como Entero
  total <- 100
  divisor <- "cero"
  Escribir total div divisor
FinAlgoritmo
''';

      const programB = '''
Algoritmo ParHermanos
  Definir total, divisor Como Entero
  total <- 100
  divisor <- 0
  Escribir total div divisor
FinAlgoritmo
''';

      final resultA = runPipeline(programA);
      expect(resultA.hasErrors, isTrue);
      expect(resultA.typeCheckResult?.hasErrors, isTrue);
      expect(
        resultA.typeCheckResult?.diagnostics.any(
          (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
        ),
        isTrue,
      );
      expect(resultA.executionResult, isA<ExecutionNotExecutable>());
      expect(resultA.runResult, isNull);

      final resultB = runPipeline(programB);
      expect(resultB.typeCheckResult?.hasErrors, isFalse);
      expect(resultB.executionResult, isA<ExecutionReady>());
      expect(resultB.finalOutcome, isA<StepHalted>());
      expect(resultB.runResult?.haltDiagnostic.code, equals(DiagnosticCode.divisionByZero));
    });

    test('Array indexing sibling pair: string index (static) vs out of bounds (runtime)', () {
      const programStatic = '''
Algoritmo ArrayHermano
  Dimension notas[5] Como Entero
  notas["tres"] <- 10
  Escribir notas[0]
FinAlgoritmo
''';

      const programRuntime = '''
Algoritmo ArrayHermano
  Dimension notas[5] Como Entero
  notas[10] <- 10
  Escribir notas[0]
FinAlgoritmo
''';

      final resStatic = runPipeline(programStatic);
      expect(resStatic.typeCheckResult?.hasErrors, isTrue);
      expect(
        resStatic.typeCheckResult?.diagnostics.any(
          (d) => d.code == DiagnosticCode.nonIntegerArrayIndex,
        ),
        isTrue,
      );
      expect(resStatic.executionResult, isA<ExecutionNotExecutable>());

      final resRuntime = runPipeline(programRuntime);
      expect(resRuntime.typeCheckResult?.hasErrors, isFalse);
      expect(resRuntime.executionResult, isA<ExecutionReady>());
      expect(resRuntime.finalOutcome, isA<StepHalted>());
      expect(
        resRuntime.runResult?.haltDiagnostic.code,
        equals(DiagnosticCode.arrayIndexOutOfRange),
      );
    });
  });
}
