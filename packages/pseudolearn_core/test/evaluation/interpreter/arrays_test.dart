import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('One-dimensional arrays (9)', () {
    test('write and read elements, base zero', () {
      const src = '''
Proceso Principal
    Dimension notas[3] Como Entero
    notas[0] <- 10
    notas[1] <- 20
    notas[2] <- 30
    Escribir notas[0], ",", notas[1], ",", notas[2]
FinProceso
''';
      expect(runProgram(src).output, equals('10,20,30\n'));
    });

    test('a full traversal with a counted loop', () {
      const src = '''
Proceso Principal
    Dimension notas[3] Como Entero
    Definir i Como Entero
    notas[0] <- 1
    notas[1] <- 2
    notas[2] <- 3
    Definir suma Como Entero
    suma <- 0
    Para i <- 0 Hasta 2 Hacer
        suma <- suma + notas[i]
    FinPara
    Escribir suma
FinProceso
''';
      expect(runProgram(src).output, equals('6\n'));
    });

    test(
        'index out of range above the top is a diagnostic with the culprit span',
        () {
      const src = '''
Proceso Principal
    Dimension notas[3] Como Entero
    Escribir notas[3]
FinProceso
''';
      final result = runProgram(src);
      expect(result.haltDiagnostic.code.name, equals('arrayIndexOutOfRange'));
    });

    test('index out of range below zero is a diagnostic', () {
      const src = '''
Proceso Principal
    Dimension notas[3] Como Entero
    Escribir notas[-1]
FinProceso
''';
      final result = runProgram(src);
      expect(result.haltDiagnostic.code.name, equals('arrayIndexOutOfRange'));
    });

    test('a zero-size array is valid, and any access is out of range', () {
      const src = '''
Proceso Principal
    Dimension vacio[0] Como Entero
    Escribir vacio[0]
FinProceso
''';
      final result = runProgram(src);
      expect(result.haltDiagnostic.code.name, equals('arrayIndexOutOfRange'));
    });
  });

  group('Two-dimensional arrays (9)', () {
    test('write and read a matrix', () {
      const src = '''
Proceso Principal
    Dimension m[2, 2] Como Entero
    m[0, 0] <- 1
    m[0, 1] <- 2
    m[1, 0] <- 3
    m[1, 1] <- 4
    Escribir m[0, 0], m[0, 1], m[1, 0], m[1, 1]
FinProceso
''';
      expect(runProgram(src).output, equals('1234\n'));
    });
  });

  group(
      'An array modified inside a subroutine (arrays pass by reference, 10.3)',
      () {
    test('the caller sees the modification made through the array parameter',
        () {
      const src = '''
SubProceso LlenarCon(datos[] Como Entero Por Referencia, valor Como Entero)
    Definir i Como Entero
    Para i <- 0 Hasta 2 Hacer
        datos[i] <- valor
    FinPara
FinSubProceso

Proceso Principal
    Dimension notas[3] Como Entero
    LlenarCon(notas, 7)
    Escribir notas[0], notas[1], notas[2]
FinProceso
''';
      expect(runProgram(src).output, equals('777\n'));
    });
  });
}
