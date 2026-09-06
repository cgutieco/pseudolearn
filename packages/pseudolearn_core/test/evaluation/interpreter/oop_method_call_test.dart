import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Method Call Tests', () {
    test('invokes void method as statement modifying object state', () {
      const source = '''
Clase Cuenta
  Definir saldo Como Entero

  Metodo Constructor(inicial Como Entero)
    Este.saldo <- inicial
  FinMetodo

  Metodo Depositar(monto Como Entero)
    Este.saldo <- Este.saldo + monto
  FinMetodo
FinClase

Algoritmo Test
  Definir c Como Cuenta
  c <- Nuevo Cuenta(100)
  c.Depositar(50)
  Escribir "Saldo final: ", c.saldo
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Saldo final: 150\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('invokes method as expression returning primitive value', () {
      const source = '''
Clase Termometro
  Definir celsius Como Real

  Metodo Constructor(c Como Real)
    Este.celsius <- c
  FinMetodo

  Metodo Fahrenheit() Como Real
    Retornar (Este.celsius * 1.8) + 32.0
  FinMetodo
FinClase

Algoritmo Test
  Definir t Como Termometro
  t <- Nuevo Termometro(25.0)
  Definir f Como Real
  f <- t.Fahrenheit()
  Escribir "Fahrenheit: ", f
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Fahrenheit: 77.0\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('method returning new object instance', () {
      const source = '''
Clase Vector2D
  Definir posX Como Entero
  Definir posY Como Entero

  Metodo Constructor(xVal Como Entero, yVal Como Entero)
    Este.posX <- xVal
    Este.posY <- yVal
  FinMetodo

  Metodo Sumar(otro Como Vector2D) Como Vector2D
    Definir res Como Vector2D
    res <- Nuevo Vector2D(Este.posX + otro.posX, Este.posY + otro.posY)
    Retornar res
  FinMetodo
FinClase

Algoritmo Test
  Definir v1, v2, v3 Como Vector2D
  v1 <- Nuevo Vector2D(1, 2)
  v2 <- Nuevo Vector2D(3, 4)
  v3 <- v1.Sumar(v2)
  Escribir "(", v3.posX, ", ", v3.posY, ")"
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('(4, 6)\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
