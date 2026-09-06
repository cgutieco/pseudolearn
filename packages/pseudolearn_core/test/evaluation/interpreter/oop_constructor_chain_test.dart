import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Constructor Chaining Tests', () {
    test('subclass constructor explicitly invokes superclass constructor', () {
      const source = '''
Clase Persona
  Definir nombre Como Cadena

  Metodo Constructor(n Como Cadena)
    Este.nombre <- n
  FinMetodo
FinClase

Clase Estudiante HeredaDe Persona
  Definir matricula Como Cadena

  Metodo Constructor(n Como Cadena, m Como Cadena)
    Super.Constructor(n)
    Este.matricula <- m
  FinMetodo
FinClase

Algoritmo Test
  Definir e Como Estudiante
  e <- Nuevo Estudiante("Lucia", "MAT-123")
  Escribir e.nombre, " - ", e.matricula
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Lucia - MAT-123\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('3-level inheritance constructor chain executes correctly', () {
      const source = '''
Clase Base
  Definir id Como Entero

  Metodo Constructor(idVal Como Entero)
    Este.id <- idVal
  FinMetodo
FinClase

Clase Media HeredaDe Base
  Definir categoria Como Cadena

  Metodo Constructor(idVal Como Entero, catVal Como Cadena)
    Super.Constructor(idVal)
    Este.categoria <- catVal
  FinMetodo
FinClase

Clase Hoja HeredaDe Media
  Definir detalle Como Cadena

  Metodo Constructor(idVal Como Entero, catVal Como Cadena, detVal Como Cadena)
    Super.Constructor(idVal, catVal)
    Este.detalle <- detVal
  FinMetodo
FinClase

Algoritmo Test
  Definir h Como Hoja
  h <- Nuevo Hoja(100, "Premium", "VIP")
  Escribir h.id, " | ", h.categoria, " | ", h.detalle
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('100 | Premium | VIP\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });
  });
}
