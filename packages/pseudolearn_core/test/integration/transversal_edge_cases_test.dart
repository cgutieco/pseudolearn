import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Transversal Edge Cases', () {
    test('empty program (header and end only) runs cleanly to completion', () {
      const source = '''
Algoritmo ProgramaVacio
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(result.output, isEmpty);
    });

    test(
        'negative array dimension size halts at runtime with negativeArraySize',
        () {
      const source = '''
Algoritmo DimensionNegativa
  Dimension arr[-3] Como Entero
  Escribir "Inalcanzable"
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.typeCheckResult?.hasErrors, isFalse);
      expect(result.executionResult, isA<ExecutionReady>());
      expect(result.finalOutcome, isA<StepHalted>());
      expect(
        result.runResult?.haltDiagnostic.code,
        equals(DiagnosticCode.negativeArraySize),
      );
      expect(result.output, isEmpty);
    });

    test(
        'zero array dimension size allows allocation but index access is out of range',
        () {
      const source = '''
Algoritmo DimensionCero
  Dimension arr[0] Como Entero
  arr[0] <- 10
  Escribir arr[0]
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.typeCheckResult?.hasErrors, isFalse);
      expect(result.executionResult, isA<ExecutionReady>());
      expect(result.finalOutcome, isA<StepHalted>());
      expect(
        result.runResult?.haltDiagnostic.code,
        equals(DiagnosticCode.arrayIndexOutOfRange),
      );
    });

    test(
        'deep recursion executes correctly on task-based trampoline without host stack overflow',
        () {
      const source = '''
SubProceso SumaRecursiva(n Como Entero) Como Entero
  Si n <= 1 Entonces
    Retornar 1
  SiNo
    Retornar n + SumaRecursiva(n - 1)
  FinSi
FinSubProceso

Algoritmo RecursionProfunda
  Definir resultado Como Entero
  resultado <- SumaRecursiva(100)
  Escribir "Suma: ", resultado
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());

      expect(result.output, equals('Suma: 5050\n'));
    });

    test(
        'single-character identifier collision: Spanish logical Y vs English valid identifier',
        () {
      const spanishCollision = '''
Algoritmo ColisionEspanol
  Definir y Como Entero
FinAlgoritmo
''';

      final spanishResult = runPipeline(spanishCollision);
      expect(
        spanishResult.allDiagnostics.map((d) => d.code),
        equals([DiagnosticCode.reservedLexemeUsedAsName]),
      );

      const englishValid = '''
algorithm EnglishSingleLetter
  define y as integer
  y <- 42
  write "Y is: ", y
endAlgorithm
''';

      final englishResult = runPipeline(
        englishValid,
        profile: const EnglishProfile.flexible(),
      );

      expect(englishResult.hasErrors, isFalse);
      expect(englishResult.finalOutcome, isA<StepFinished>());
      expect(englishResult.output, equals('Y is: 42\n'));
    });
  });
}
