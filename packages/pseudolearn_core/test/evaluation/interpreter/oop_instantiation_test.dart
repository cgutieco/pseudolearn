import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Instantiation Tests', () {
    test('instantiates class with implicit constructor', () {
      const source = '''
Clase Punto
  Definir coordX Como Entero
  Definir coordY Como Entero
FinClase

Algoritmo Test
  Definir p Como Punto
  p <- Nuevo Punto()
  p.coordX <- 10
  p.coordY <- 20
  Escribir p.coordX, " ", p.coordY
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('10 20\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('instantiates class with explicit constructor and arguments', () {
      const source = '''
Clase Persona
  Definir nombre Como Cadena
  Definir edad Como Entero

  Metodo Constructor(n Como Cadena, e Como Entero)
    Este.nombre <- n
    Este.edad <- e
  FinMetodo
FinClase

Algoritmo Test
  Definir p Como Persona
  p <- Nuevo Persona("Carlos", 30)
  Escribir p.nombre, " tiene ", p.edad, " anios"
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Carlos tiene 30 anios\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('instantiates multiple distinct instances with independent states', () {
      const source = '''
Clase Contador
  Definir valor Como Entero

  Metodo Constructor(inicial Como Entero)
    Este.valor <- inicial
  FinMetodo
FinClase

Algoritmo Test
  Definir c1, c2 Como Contador
  c1 <- Nuevo Contador(5)
  c2 <- Nuevo Contador(10)
  c1.valor <- c1.valor + 1
  Escribir c1.valor, " ", c2.valor
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('6 10\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
