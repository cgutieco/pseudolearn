import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

List<DecisionEvaluatedEvent> decisionsOf(String source) =>
    runProgram(source).events.whereType<DecisionEvaluatedEvent>().toList();

List<DecisionBranch> branchesOf(String source) =>
    decisionsOf(source).map((event) => event.branch).toList();

void main() {
  group('Para', () {
    test('evaluates its condition once per turn plus the closing one', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 3 Con Paso 1 Hacer
        Escribir i
    FinPara
FinProceso
''';
      expect(
        branchesOf(src),
        equals([
          DecisionBranch.affirmative,
          DecisionBranch.affirmative,
          DecisionBranch.affirmative,
          DecisionBranch.negative,
        ]),
      );
    });

    test('a range that never runs still reports one negative decision', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 5 Hasta 1 Con Paso 1 Hacer
        Escribir i
    FinPara
FinProceso
''';
      expect(branchesOf(src), equals([DecisionBranch.negative]));
    });

    test('an empty body still reports one decision per turn', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 2 Con Paso 1 Hacer
    FinPara
FinProceso
''';
      expect(branchesOf(src), hasLength(3));
    });

    test('the reported span covers the header alone, on a single line', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 2 Con Paso 1 Hacer
        Escribir i
    FinPara
FinProceso
''';
      final span = decisionsOf(src).first.decisionSpan;
      expect(span.crossesLines, isFalse);
      expect(span.start.line, equals(3));
    });

    test('the snapshot carries the control variable already assigned', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 7 Hasta 7 Con Paso 1 Hacer
        Escribir i
    FinPara
FinProceso
''';
      final snapshot = decisionsOf(src).first.snapshot!;
      final variable = snapshot.frames.last.variables
          .firstWhere((entry) => entry.name == 'i');
      expect((variable.value as IntegerValue).value.toHostInt(), equals(7));
    });
  });

  group('Mientras', () {
    test('a condition false on entry reports one negative decision', () {
      const src = '''
Proceso Principal
    Mientras Falso Hacer
        Escribir "nunca"
    FinMientras
FinProceso
''';
      expect(branchesOf(src), equals([DecisionBranch.negative]));
    });

    test('every turn reports the value of the condition as written', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    i <- 0
    Mientras i < 2 Hacer
        i <- i + 1
    FinMientras
FinProceso
''';
      expect(
        branchesOf(src),
        equals([
          DecisionBranch.affirmative,
          DecisionBranch.affirmative,
          DecisionBranch.negative,
        ]),
      );
    });
  });

  group('Repetir', () {
    test('the branch names the condition, so leaving the loop is affirmative',
        () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    i <- 0
    Repetir
        i <- i + 1
    Hasta Que i >= 2
FinProceso
''';
      expect(
        branchesOf(src),
        equals([DecisionBranch.negative, DecisionBranch.affirmative]),
      );
    });
  });

  group('Si', () {
    test('a false condition without else still reports a decision', () {
      const src = '''
Proceso Principal
    Si Falso Entonces
        Escribir "si"
    FinSi
FinProceso
''';
      expect(branchesOf(src), equals([DecisionBranch.negative]));
    });

    test('a taken then branch is affirmative', () {
      const src = '''
Proceso Principal
    Si Verdadero Entonces
        Escribir "si"
    FinSi
FinProceso
''';
      expect(branchesOf(src), equals([DecisionBranch.affirmative]));
    });
  });

  group('Segun', () {
    const preamble = '''
Proceso Principal
    Definir x Como Entero
    x <- 2
''';

    test('a matching case reports its index', () {
      const src = '''
$preamble    Segun x Hacer
        1:
            Escribir "uno"
        2:
            Escribir "dos"
    FinSegun
FinProceso
''';
      final decision = decisionsOf(src).single;
      expect(decision.branch, equals(DecisionBranch.selectedCase));
      expect(decision.caseIndex, equals(1));
    });

    test('falling through to the default case reports it without index', () {
      const src = '''
$preamble    Segun x Hacer
        9:
            Escribir "nueve"
        De Otro Modo:
            Escribir "otro"
    FinSegun
FinProceso
''';
      final decision = decisionsOf(src).single;
      expect(decision.branch, equals(DecisionBranch.defaultCase));
      expect(decision.caseIndex, isNull);
    });

    test('no match and no default reports that no branch was taken', () {
      const src = '''
$preamble    Segun x Hacer
        9:
            Escribir "nueve"
    FinSegun
FinProceso
''';
      final decision = decisionsOf(src).single;
      expect(decision.branch, equals(DecisionBranch.negative));
      expect(decision.caseIndex, isNull);
    });
  });

  group('without an observer', () {
    test('a program with every decision kind still runs to completion', () {
      const src = '''
Proceso Principal
    Definir i Como Entero
    Para i <- 1 Hasta 2 Con Paso 1 Hacer
        Si i = 1 Entonces
            Escribir i
        FinSi
    FinPara
FinProceso
''';
      final interpreter = readyInterpreter(src);
      final outcome = const ProgramRunner().runToCompletion(interpreter);
      expect(outcome, isA<StepFinished>());
    });
  });
}
