import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('Assignment and declaration', () {
    test('a declared variable is assigned and read back', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 5
    Escribir x
FinProceso
''';
      expect(runProgram(src).output, equals('5\n'));
    });

    test('reassigning replaces the previous value', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 5
    x <- 10
    Escribir x
FinProceso
''';
      expect(runProgram(src).output, equals('10\n'));
    });

    test('an integer assigned to a real variable widens', () {
      const src = '''
Proceso Principal
    Definir x Como Real
    x <- 5
    Escribir x
FinProceso
''';
      expect(runProgram(src).output, equals('5.0\n'));
    });
  });

  group('Escribir', () {
    test('a list of expressions concatenates without an automatic separator',
        () {
      const src = '''
Proceso Principal
    Escribir "Total: ", 42
FinProceso
''';
      expect(runProgram(src).output, equals('Total: 42\n'));
    });

    test('Sin Saltar suppresses the trailing newline', () {
      const src = '''
Proceso Principal
    Escribir "a" Sin Saltar
    Escribir "b"
FinProceso
''';
      expect(runProgram(src).output, equals('ab\n'));
    });

    test('zero expressions without the modifier emits a blank line', () {
      const src = '''
Proceso Principal
    Escribir
FinProceso
''';
      expect(runProgram(src).output, equals('\n'));
    });

    test('zero expressions with the modifier emits nothing', () {
      const src = '''
Proceso Principal
    Escribir Sin Saltar
FinProceso
''';
      expect(runProgram(src).output, equals(''));
    });
  });
}
