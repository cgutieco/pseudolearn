import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void _expectHalts(String source, String code) {
  final result = runProgram(source);
  expect(result.haltDiagnostic.code.name, equals(code));
}

void main() {
  group('Division by zero, all three forms (12.3, 12.12)', () {
    test(
        '/',
        () => _expectHalts(
            'Proceso Principal\nEscribir 1 / 0\nFinProceso', 'divisionByZero'));
    test(
        'div',
        () => _expectHalts('Proceso Principal\nEscribir 1 div 0\nFinProceso',
            'divisionByZero'));
    test(
        'mod',
        () => _expectHalts('Proceso Principal\nEscribir 1 mod 0\nFinProceso',
            'divisionByZero'));
  });

  group('Integer overflow, both borders', () {
    test('addition beyond the maximum', () {
      const src = '''
Proceso Principal
    Escribir 9223372036854775807 + 1
FinProceso
''';
      _expectHalts(src, 'integerOverflow');
    });

    test('the operation right at the border does not overflow', () {
      const src = '''
Proceso Principal
    Escribir 9223372036854775807 - 1
FinProceso
''';
      final result = runProgram(src);
      expect(result.output, equals('9223372036854775806\n'));
    });

    test('subtraction beyond the minimum', () {
      const src = '''
Proceso Principal
    Escribir -9223372036854775807 - 2
FinProceso
''';
      _expectHalts(src, 'integerOverflow');
    });
  });

  group('Negative integer exponent', () {
    test('base and exponent both integer, exponent negative', () {
      _expectHalts('Proceso Principal\nEscribir 2 ^ (0 - 1)\nFinProceso',
          'negativeIntegerExponent');
    });
  });

  group('Uninitialized read, detected at execution (decision 3)', () {
    test('reading a declared-but-unassigned variable halts', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    Escribir x
FinProceso
''';
      _expectHalts(src, 'uninitializedVariableRead');
    });
  });

  group('String-to-number conversion failure', () {
    test('AEntero of non-numeric text', () {
      _expectHalts('Proceso Principal\nEscribir AEntero("hola")\nFinProceso',
          'stringToNumberConversionFailed');
    });
  });

  group('String position out of range', () {
    test('CaracterEn beyond the string length', () {
      _expectHalts(
          'Proceso Principal\nEscribir CaracterEn("hola", 10)\nFinProceso',
          'stringPositionOutOfRange');
    });
  });

  group('Invalid character code', () {
    test('CaracterDesde with a code outside the valid Unicode range', () {
      _expectHalts(
          'Proceso Principal\nEscribir CaracterDesde(0 - 1)\nFinProceso',
          'invalidCharacterCode');
    });
  });

  group('Array size and index diagnostics (9)', () {
    test('a negative dimension size halts', () {
      const src = '''
Proceso Principal
    Dimension notas[0 - 1] Como Entero
FinProceso
''';
      _expectHalts(src, 'negativeArraySize');
    });
  });

  group('Zero step in a counted loop', () {
    test('Para with a step of zero halts', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 5 Con Paso 0 Hacer
        Escribir i
    FinPara
FinProceso
''';
      _expectHalts(src, 'zeroStepInCountedLoop');
    });
  });

  group('A halted run stops there: nothing after the fault executes', () {
    test('output before the fault is kept, nothing after it appears', () {
      const src = '''
Proceso Principal
    Escribir "antes"
    Escribir 1 / 0
    Escribir "despues"
FinProceso
''';
      final result = runProgram(src);
      expect(result.output, equals('antes\n'));
    });
  });

  group('A program with a static error never executes at all (D4)', () {
    test(
        'a type error prevents Interpreter.start from producing a ready interpreter',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- "hola"
FinProceso
''';
      final program = analyzeProgram(src);
      final result = Interpreter.start(program: program);
      expect(result, isA<ExecutionNotExecutable>());
      expect(
        (result as ExecutionNotExecutable).reason,
        equals(NotExecutableReason.analysisHasErrors),
      );
    });
  });
}
