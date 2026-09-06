import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Super Method Call Tests', () {
    test('Super.Metodo() calls superclass method statically and avoids recursion', () {
      const source = '''
Clase Base
  Metodo Saludar() Como Cadena
    Retornar "Hola"
  FinMetodo
FinClase

Clase Decorada HeredaDe Base
  Metodo Saludar() Como Cadena
    Retornar Super.Saludar() + ", mundo!"
  FinMetodo
FinClase

Algoritmo Test
  Definir d Como Decorada
  d <- Nuevo Decorada()
  Escribir d.Saludar()
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Hola, mundo!\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('multi-level Super chaining across 3 hierarchy levels', () {
      const source = '''
Clase Nivel1
  Metodo Identificar() Como Cadena
    Retornar "Nivel 1"
  FinMetodo
FinClase

Clase Nivel2 HeredaDe Nivel1
  Metodo Identificar() Como Cadena
    Retornar Super.Identificar() + " -> Nivel 2"
  FinMetodo
FinClase

Clase Nivel3 HeredaDe Nivel2
  Metodo Identificar() Como Cadena
    Retornar Super.Identificar() + " -> Nivel 3"
  FinMetodo
FinClase

Algoritmo Test
  Definir n Como Nivel3
  n <- Nuevo Nivel3()
  Escribir n.Identificar()
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Nivel 1 -> Nivel 2 -> Nivel 3\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
