import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Runtime Visibility Tests (Privado / Publico)', () {
    test('internal methods can access private fields and private methods', () {
      const source = '''
Clase Boveda
  Privado Definir secreto Como Entero

  Metodo Constructor(s Como Entero)
    Este.secreto <- s
  FinMetodo

  Privado Metodo ObtenerInterno() Como Entero
    Retornar Este.secreto
  FinMetodo

  Publico Metodo Revelar() Como Entero
    Retornar Este.ObtenerInterno()
  FinMetodo
FinClase

Algoritmo Test
  Definir b Como Boveda
  b <- Nuevo Boveda(777)
  Escribir "Secreto revelado: ", b.Revelar()
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Secreto revelado: 777\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('accessing private member from outside class is rejected at runtime with privateMemberAccess', () {
      const source = '''
Clase Secreta
  Privado Definir codigo Como Entero

  Metodo Constructor()
    Este.codigo <- 123
  FinMetodo
FinClase

Algoritmo Test
  Definir s Como Secreta
  s <- Nuevo Secreta()
  Escribir s.codigo
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.finalOutcome, isA<StepHalted>());
      expect(result.haltDiagnostic.code, equals(DiagnosticCode.privateMemberAccess));
      expect(
        (result.haltDiagnostic.arguments['lexeme'] as LexemeDiagnosticArgument).lexeme,
        equals('codigo'),
      );
    });
  });
}
