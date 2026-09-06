import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

String _writeProgram(String expression) => '''
Proceso Principal
    Escribir $expression
FinProceso
''';

void main() {
  group('Arithmetic operators', () {
    test('addition, subtraction, multiplication of integers', () {
      expect(runProgram(_writeProgram('2 + 3')).output, equals('5\n'));
      expect(runProgram(_writeProgram('5 - 8')).output, equals('-3\n'));
      expect(runProgram(_writeProgram('6 * 7')).output, equals('42\n'));
    });

    test('division of two integers always gives a real', () {
      expect(runProgram(_writeProgram('5 / 2')).output, equals('2.5\n'));
      expect(runProgram(_writeProgram('4 / 2')).output, equals('2.0\n'));
    });

    test('div and mod are integer-only, truncating toward zero', () {
      expect(runProgram(_writeProgram('7 div 2')).output, equals('3\n'));
      expect(runProgram(_writeProgram('7 mod 2')).output, equals('1\n'));
      expect(runProgram(_writeProgram('-7 div 2')).output, equals('-3\n'));
      expect(runProgram(_writeProgram('-7 mod 2')).output, equals('-1\n'));
    });

    test('power with integer base and exponent stays integer', () {
      expect(runProgram(_writeProgram('2 ^ 10')).output, equals('1024\n'));
    });

    test('mixed integer and real widens to real', () {
      expect(runProgram(_writeProgram('1 + 2.5')).output, equals('3.5\n'));
    });

    test('unary minus and plus', () {
      expect(runProgram(_writeProgram('-5')).output, equals('-5\n'));
      expect(runProgram(_writeProgram('+5')).output, equals('5\n'));
      expect(runProgram(_writeProgram('-(2 + 3)')).output, equals('-5\n'));
    });
  });

  group('Concatenation', () {
    test('string with string, and string with character', () {
      expect(runProgram(_writeProgram('"a" + "b"')).output, equals('ab\n'));
    });
  });

  group('Relational and equality operators', () {
    test('numeric comparisons', () {
      expect(runProgram(_writeProgram('3 < 5')).output, equals('Verdadero\n'));
      expect(runProgram(_writeProgram('5 <= 5')).output, equals('Verdadero\n'));
      expect(runProgram(_writeProgram('3 > 5')).output, equals('Falso\n'));
    });

    test('equality between comparable values', () {
      expect(runProgram(_writeProgram('3 = 3')).output, equals('Verdadero\n'));
      expect(runProgram(_writeProgram('3 <> 4')).output, equals('Verdadero\n'));
    });

    test('string comparison is lexicographic', () {
      expect(runProgram(_writeProgram('"abc" < "abd"')).output,
          equals('Verdadero\n'));
    });
  });

  group('Logical operators and short-circuit (5, 12.3)', () {
    test('not, y, o on plain values', () {
      expect(
          runProgram(_writeProgram('NO Verdadero')).output, equals('Falso\n'));
      expect(runProgram(_writeProgram('Verdadero Y Falso')).output,
          equals('Falso\n'));
      expect(runProgram(_writeProgram('Falso O Verdadero')).output,
          equals('Verdadero\n'));
    });

    test(
        'Y short-circuits: a second operand that would fail is never evaluated',
        () {
      const src = '''
Proceso Principal
    Definir b Como Logico
    b <- Falso Y (1 / 0 > 0)
    Escribir b
FinProceso
''';
      final result = runProgram(src);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(result.output, equals('Falso\n'));
    });

    test(
        'O short-circuits: a second operand that would fail is never evaluated',
        () {
      const src = '''
Proceso Principal
    Definir b Como Logico
    b <- Verdadero O (1 / 0 > 0)
    Escribir b
FinProceso
''';
      final result = runProgram(src);
      expect(result.finalOutcome, isA<StepFinished>());
      expect(result.output, equals('Verdadero\n'));
    });
  });

  group('Operator precedence, exercised through real programs', () {
    test('multiplication binds tighter than addition', () {
      expect(runProgram(_writeProgram('2 + 3 * 4')).output, equals('14\n'));
    });

    test('power associates to the right', () {
      expect(runProgram(_writeProgram('2 ^ 3 ^ 2')).output, equals('512\n'));
    });

    test('parentheses override precedence', () {
      expect(runProgram(_writeProgram('(2 + 3) * 4')).output, equals('20\n'));
    });
  });

  group('Expression evaluation involving a call (D1/D2)', () {
    test('a call nested inside an arithmetic expression is evaluated in place',
        () {
      const src = '''
SubProceso Doble(x Como Entero) Como Entero
    Retornar x * 2
FinSubProceso

Proceso Principal
    Escribir 1 + Doble(3)
FinProceso
''';
      expect(runProgram(src).output, equals('7\n'));
    });
  });
}
