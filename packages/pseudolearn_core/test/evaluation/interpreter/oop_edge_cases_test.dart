import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Edge Cases Tests', () {
    test('empty class instantiates and compares equal to self', () {
      const source = '''
Clase Vacia
FinClase

Algoritmo Test
  Definir v Como Vacia
  v <- Nuevo Vacia()
  v <- v
  Si v = v Entonces
    Escribir "Auto-igualdad correcta"
  FinSi
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Auto-igualdad correcta\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('array of objects can store distinct instances and invoke methods on elements', () {
      const source = '''
Clase Elemento
  Definir valor Como Entero

  Metodo Constructor(v Como Entero)
    Este.valor <- v
  FinMetodo

  Metodo ObtenerValor() Como Entero
    Retornar Este.valor
  FinMetodo
FinClase

Algoritmo Test
  Dimension items[3] Como Elemento
  items[0] <- Nuevo Elemento(10)
  items[1] <- Nuevo Elemento(20)
  items[2] <- Nuevo Elemento(30)

  Definir total Como Entero
  total <- items[0].ObtenerValor() + items[1].ObtenerValor() + items[2].ObtenerValor()
  Escribir "Total: ", total
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Total: 60\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('infinite method recursion triggers recursionDepthExceeded diagnostic', () {
      const source = '''
Clase Recursiva
  Metodo Bucle()
    Este.Bucle()
  FinMetodo
FinClase

Algoritmo Test
  Definir r Como Recursiva
  r <- Nuevo Recursiva()
  r.Bucle()
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.finalOutcome, isA<StepHalted>());
      expect(result.haltDiagnostic.code, equals(DiagnosticCode.recursionDepthExceeded));
    });
  });
}
