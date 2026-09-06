import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('OOP Member Access Tests', () {
    test('reads and writes object members as expressions and assignment targets', () {
      const source = '''
Clase Rectangulo
  Definir base Como Entero
  Definir altura Como Entero
FinClase

Algoritmo Test
  Definir r Como Rectangulo
  r <- Nuevo Rectangulo()
  r.base <- 4
  r.altura <- 5
  Definir area Como Entero
  area <- r.base * r.altura
  Escribir "Area: ", area
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Area: 20\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('reads object member with Leer statement', () {
      const source = '''
Clase Usuario
  Definir edad Como Entero
FinClase

Algoritmo Test
  Definir u Como Usuario
  u <- Nuevo Usuario()
  Leer u.edad
  Escribir "Edad ingresada: ", u.edad
FinAlgoritmo
''';
      final result = runProgram(source, inputs: ['25']);
      expect(result.output, equals('Edad ingresada: 25\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('nested member access reads and writes chained object fields', () {
      const source = '''
Clase Direccion
  Definir calle Como Cadena
  Definir numCalle Como Entero
FinClase

Clase Empleado
  Definir nombre Como Cadena
  Definir domicilio Como Direccion
FinClase

Algoritmo Test
  Definir emp Como Empleado
  emp <- Nuevo Empleado()
  emp.nombre <- "Marta"
  emp.domicilio <- Nuevo Direccion()
  emp.domicilio.calle <- "Av. Principal"
  emp.domicilio.numCalle <- 123
  Escribir emp.nombre, " vive en ", emp.domicilio.calle, " ", emp.domicilio.numCalle
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.output, equals('Marta vive en Av. Principal 123\n'));
      expect(result.finalOutcome, isA<StepFinished>());
    });

    test('halts with uninitializedVariableRead when reading unassigned field', () {
      const source = '''
Clase Caja
  Definir peso Como Entero
FinClase

Algoritmo Test
  Definir c Como Caja
  c <- Nuevo Caja()
  Escribir c.peso
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.finalOutcome, isA<StepHalted>());
      expect(result.haltDiagnostic.code, equals(DiagnosticCode.uninitializedVariableRead));
      expect(
        (result.haltDiagnostic.arguments['lexeme'] as LexemeDiagnosticArgument).lexeme,
        equals('peso'),
      );
    });

    test('halts with uninitializedVariableRead when accessing member of uninstantiated variable', () {
      const source = '''
Clase Caja
  Definir peso Como Entero
FinClase

Algoritmo Test
  Definir c Como Caja
  Escribir c.peso
FinAlgoritmo
''';
      final result = runProgram(source);
      expect(result.finalOutcome, isA<StepHalted>());
      expect(result.haltDiagnostic.code, equals(DiagnosticCode.uninitializedVariableRead));
      expect(
        (result.haltDiagnostic.arguments['lexeme'] as LexemeDiagnosticArgument).lexeme,
        equals('c'),
      );
    });
  });
}
