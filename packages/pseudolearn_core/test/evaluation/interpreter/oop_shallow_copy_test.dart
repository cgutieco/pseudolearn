import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Shallow Copy Tests (Copiar)', () {
    test('Copiar creates new instance with independent primitive fields', () {
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
  Definir p1, p2 Como Persona
  p1 <- Nuevo Persona("Carlos", 30)
  p2 <- Copiar(p1)

  p2.edad <- 35
  p2.nombre <- "Carlos Jr."

  Escribir "p1: ", p1.nombre, " (", p1.edad, ") | p2: ", p2.nombre, " (", p2.edad, ")"
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('p1: Carlos (30) | p2: Carlos Jr. (35)\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('Copiar creates shallow copy where nested object references are shared', () {
      const source = '''
Clase Direccion
  Definir calle Como Cadena

  Metodo Constructor(c Como Cadena)
    Este.calle <- c
  FinMetodo
FinClase

Clase Cliente
  Definir nombre Como Cadena
  Definir dir Como Direccion

  Metodo Constructor(n Como Cadena, d Como Direccion)
    Este.nombre <- n
    Este.dir <- d
  FinMetodo
FinClase

Algoritmo Test
  Definir d Como Direccion
  d <- Nuevo Direccion("Calle Luna")

  Definir c1, c2 Como Cliente
  c1 <- Nuevo Cliente("Ana", d)
  c2 <- Copiar(c1)

  c2.nombre <- "Beatriz"
  c2.dir.calle <- "Calle Sol"

  Escribir c1.nombre, " en ", c1.dir.calle, " | ", c2.nombre, " en ", c2.dir.calle
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Ana en Calle Sol | Beatriz en Calle Sol\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
