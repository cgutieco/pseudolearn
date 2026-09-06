import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Flexible Profile Full Inference Chain', () {
    test('exercises inference (info), widening (info), undeclared (warning) and conflict (error)', () {
      const source = '''
Algoritmo CadenaInferencia
  val <- 10
  val <- 25.5
  val <- "conflicto incompatible"
  Escribir val
FinAlgoritmo
''';

      final result = runPipeline(
        source,
        profile: const ClassicSpanishProfile.flexible(),
      );

      final diags = result.allDiagnostics;

      final infoDiags =
          diags.where((d) => d.severity == Severity.info).toList();
      final warningDiags =
          diags.where((d) => d.severity == Severity.warning).toList();
      final errorDiags =
          diags.where((d) => d.severity == Severity.error).toList();

      expect(infoDiags, isNotEmpty);
      expect(
        infoDiags.any((d) => d.code == DiagnosticCode.inferredVariableType),
        isTrue,
      );
      expect(
        infoDiags.any((d) => d.code == DiagnosticCode.widenedVariableType),
        isTrue,
      );

      expect(warningDiags, isNotEmpty);
      expect(
        warningDiags.any((d) => d.code == DiagnosticCode.undeclaredVariable),
        isTrue,
      );

      expect(errorDiags, isNotEmpty);
      expect(
        errorDiags.any(
          (d) => d.code == DiagnosticCode.typeConflictOnInferredVariable,
        ),
        isTrue,
      );

      expect(result.executionResult, isA<ExecutionNotExecutable>());
    });

    test('runtime dynamic inference on Leer statement', () {
      const source = '''
Algoritmo InferenciaLectura
  Leer entrada
  Escribir "Leido: ", entrada
FinAlgoritmo
''';

      final result = runPipeline(
        source,
        profile: const ClassicSpanishProfile.flexible(),
        inputs: ['456'],
      );

      expect(result.hasErrors, isFalse);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(result.output, equals('Leido: 456\n'));

      final emittedDiags = result.events
          .whereType<DiagnosticEmittedEvent>()
          .map((e) => e.diagnostic)
          .toList();

      expect(
        emittedDiags.any((d) => d.code == DiagnosticCode.inferredVariableType),
        isTrue,
      );
    });
  });
}
