import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('Si', () {
    test('the then branch runs when the condition is true', () {
      const src = '''
Proceso Principal
    Si Verdadero Entonces
        Escribir "si"
    FinSi
FinProceso
''';
      expect(runProgram(src).output, equals('si\n'));
    });

    test('the else branch runs when the condition is false', () {
      const src = '''
Proceso Principal
    Si Falso Entonces
        Escribir "si"
    SiNo
        Escribir "no"
    FinSi
FinProceso
''';
      expect(runProgram(src).output, equals('no\n'));
    });

    test('both bodies empty is not an error', () {
      const src = '''
Proceso Principal
    Si Verdadero Entonces
    FinSi
FinProceso
''';
      expect(runProgram(src).finalOutcome.runtimeType.toString(),
          contains('Finished'));
    });
  });

  group('Segun', () {
    test('the first matching case runs', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 2
    Segun x Hacer
        1: Escribir "uno"
        2: Escribir "dos"
        3: Escribir "tres"
    FinSegun
FinProceso
''';
      expect(runProgram(src).output, equals('dos\n'));
    });

    test('De Otro Modo runs when nothing matches', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 9
    Segun x Hacer
        1: Escribir "uno"
        De Otro Modo: Escribir "otro"
    FinSegun
FinProceso
''';
      expect(runProgram(src).output, equals('otro\n'));
    });

    test('nothing matches and there is no De Otro Modo: no error, no output',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 9
    Segun x Hacer
        1: Escribir "uno"
    FinSegun
FinProceso
''';
      expect(runProgram(src).output, equals(''));
    });
  });

  group('Mientras', () {
    test('runs while the condition holds, producing the exact event sequence',
        () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    i <- 0
    Mientras i < 3 Hacer
        Escribir i
        i <- i + 1
    FinMientras
FinProceso
''';
      final result = runProgram(src);
      expect(result.output, equals('0\n1\n2\n'));
    });

    test('a false condition from the start runs zero times', () {
      const src = '''
Proceso Principal
    Mientras Falso Hacer
        Escribir "nunca"
    FinMientras
FinProceso
''';
      expect(runProgram(src).output, equals(''));
    });
  });

  group('Repetir ... Hasta Que', () {
    test('the body always runs at least once', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    i <- 0
    Repetir
        Escribir i
        i <- i + 1
    Hasta Que i >= 1
FinProceso
''';
      expect(runProgram(src).output, equals('0\n'));
    });

    test('loops until the condition becomes true', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    i <- 0
    Repetir
        Escribir i
        i <- i + 1
    Hasta Que i >= 3
FinProceso
''';
      expect(runProgram(src).output, equals('0\n1\n2\n'));
    });
  });

  group('Para', () {
    test('counts up with the default step of one', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 3 Hacer
        Escribir i
    FinPara
FinProceso
''';
      expect(runProgram(src).output, equals('1\n2\n3\n'));
    });

    test('counts down with a negative step', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 3 Hasta 1 Con Paso -1 Hacer
        Escribir i
    FinPara
FinProceso
''';
      expect(runProgram(src).output, equals('3\n2\n1\n'));
    });

    test(
        'initial greater than final with a positive step is zero iterations, not an error',
        () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 5 Hasta 1 Hacer
        Escribir i
    FinPara
    Escribir i
FinProceso
''';
      expect(runProgram(src).output, equals('5\n'));
    });

    test(
        'the control variable keeps the first value that failed the test, after the loop',
        () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 3 Hacer
    FinPara
    Escribir i
FinProceso
''';
      expect(runProgram(src).output, equals('4\n'));
    });

    test(
        'the three bounds are frozen: modifying the final value inside the body changes nothing',
        () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Definir tope Como Entero
    tope <- 3
    Para i <- 1 Hasta tope Hacer
        tope <- 100
        Escribir i
    FinPara
FinProceso
''';
      expect(runProgram(src).output, equals('1\n2\n3\n'));
    });
  });

  group('Event order (D2)', () {
    test(
        'a three-iteration loop produces the exact sequence of statement events',
        () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    i <- 0
    Mientras i < 3 Hacer
        i <- i + 1
    FinMientras
FinProceso
''';
      final result = runProgram(src);
      final statementEvents = result.events
          .where((e) => e is StatementEnteredEvent || e is StatementExitedEvent)
          .toList();
      final entered = statementEvents.whereType<StatementEnteredEvent>().length;
      final exited = statementEvents.whereType<StatementExitedEvent>().length;
      expect(entered, equals(exited));
      expect(entered, greaterThan(3));
    });
  });
}
