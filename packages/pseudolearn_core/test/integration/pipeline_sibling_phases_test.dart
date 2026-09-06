import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';
import 'integration_test_harness.dart';

void main() {
  group('Integration: Pipeline Sibling Phases Isolation', () {
    test('Phase 1 (Lexer Error): fails at tokenization, clean of previous phases', () {
      const source = '''
Algoritmo Fase1Lexer
  Definir msg Como Cadena
  msg <- "cadena sin cerrar al final
  Escribir msg
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.lexerResult.diagnostics.any((d) => d.code == DiagnosticCode.unterminatedString), isTrue);
      expect(result.resolutionResult, isNull);
      expect(result.typeCheckResult, isNull);
      expect(result.runResult, isNull);
    });

    test('Phase 2 (Parser Error): clean lexically, fails at parsing', () {
      const source = '''
Algoritmo Fase2Parser
  Definir x Como Entero
  x <- 10
  Si x > 5
    Escribir "Mayor"
  FinSi
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.lexerResult.diagnostics, isEmpty);
      expect(result.parseResult.diagnostics, isNotEmpty);
      expect(result.resolutionResult, isNull);
      expect(result.typeCheckResult, isNull);
      expect(result.runResult, isNull);
    });

    test('Phase 3 (Symbol Resolution Error): clean in lexer and parser, fails at resolution', () {
      const source = '''
Algoritmo Fase3Simbolos
  Definir entidad Como TipoNoExistente
  Escribir "Inaccesible"
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.lexerResult.diagnostics, isEmpty);
      expect(result.parseResult.diagnostics, isEmpty);
      expect(result.resolutionResult, isNotNull);
      expect(result.resolutionResult!.hasErrors, isTrue);
      expect(
        result.resolutionResult!.diagnostics.any(
          (d) => d.code == DiagnosticCode.undeclaredClass,
        ),
        isTrue,
      );
      expect(result.typeCheckResult, isNull);
      expect(result.runResult, isNull);
    });

    test('Phase 4 (Type Check Error): clean in lexer, parser, symbols, fails at type checker', () {
      const source = '''
Algoritmo Fase4Tipos
  Definir valor Como Entero
  valor <- "esto es una cadena"
  Escribir valor
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.lexerResult.diagnostics, isEmpty);
      expect(result.parseResult.diagnostics, isEmpty);
      expect(result.resolutionResult!.hasErrors, isFalse);
      expect(result.typeCheckResult, isNotNull);
      expect(result.typeCheckResult!.hasErrors, isTrue);
      expect(
        result.typeCheckResult!.diagnostics.any(
          (d) => d.code == DiagnosticCode.incompatibleTypesInAssignment,
        ),
        isTrue,
      );
      expect(result.executionResult, isA<ExecutionNotExecutable>());
      expect(result.runResult, isNull);
    });

    test('Phase 5 (Runtime Error): clean in all static checks, fails during interpreter step', () {
      const source = '''
Algoritmo Fase5Ejecucion
  Definir a, b Como Entero
  a <- 50
  b <- 0
  Escribir a div b
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.lexerResult.diagnostics, isEmpty);
      expect(result.parseResult.diagnostics, isEmpty);
      expect(result.resolutionResult!.hasErrors, isFalse);
      expect(result.typeCheckResult!.hasErrors, isFalse);
      expect(result.executionResult, isA<ExecutionReady>());
      expect(result.finalOutcome, isA<StepHalted>());
      expect(result.runResult?.haltDiagnostic.code, equals(DiagnosticCode.divisionByZero));
    });

    test('Phase 6 (Execution Success): clean in all phases, runs to completion', () {
      const source = '''
Algoritmo Fase6Exito
  Definir a, b, res Como Entero
  a <- 50
  b <- 5
  res <- a div b
  Escribir "Resultado: ", res
FinAlgoritmo
''';

      final result = runPipeline(source);
      expect(result.hasErrors, isFalse);
      expect(result.lexerResult.diagnostics, isEmpty);
      expect(result.parseResult.diagnostics, isEmpty);
      expect(result.resolutionResult!.hasErrors, isFalse);
      expect(result.typeCheckResult!.hasErrors, isFalse);
      expect(result.executionResult, isA<ExecutionReady>());
      expect(result.finalOutcome, isA<StepFinished>());
      expect(result.output, equals('Resultado: 10\n'));
    });
  });
}
