import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'package:pseudolearn_app/engine/exercise/behaviour_checker.dart';

const String _square = '''
Algoritmo Cuadrado
  Definir n Como Entero
  Leer n
  Escribir n * n
FinAlgoritmo
''';

const String _impostor = '''
Algoritmo Impostor
  Definir n Como Entero
  Leer n
  Escribir 16
FinAlgoritmo
''';

const String _doesNotParse = '''
Algoritmo Roto
  Definir Como Entero
FinAlgoritmo
''';

const String _dividesByZero = '''
Algoritmo Rompe
  Definir n Como Entero
  Definir cero Como Entero
  Leer n
  cero <- 0
  Escribir n / cero
FinAlgoritmo
''';

const String _neverEnds = '''
Algoritmo Eterno
  Definir i Como Entero
  i <- 0
  Mientras i >= 0 Hacer
    i <- i + 1
  FinMientras
FinAlgoritmo
''';

const String _readsTwice = '''
Algoritmo Suma
  Definir a Como Entero
  Definir b Como Entero
  Leer a
  Leer b
  Escribir a + b
FinAlgoritmo
''';

const String _writesNothing = '''
Algoritmo Callado
  Definir n Como Entero
  n <- 1
FinAlgoritmo
''';

ExerciseCase _numericCase(List<String> inputs, List<String> outputs) =>
    ExerciseCase(
      inputs: inputs,
      expectedOutputs: outputs,
      expectedValueKind: ExpectedValueKind.numeric,
    );

ExerciseCheckResult _check(
  String sourceCode, {
  List<ExerciseCase> visible = const [],
  List<ExerciseCase> hidden = const [],
  int stepLimit = BehaviourChecker.defaultStepLimit,
}) {
  final checker = BehaviourChecker(
    execution: CoreProgramExecution(),
    analyzer: CoreProgramAnalyzer(),
    stepLimit: stepLimit,
  );
  return checker.checkBehaviour(
    sourceCode: sourceCode,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
    visibleCases: visible,
    hiddenCases: hidden,
  );
}

void main() {
  group('BehaviourChecker happy path', () {
    test('a correct program passes every case', () {
      final result = _check(
        _square,
        visible: [_numericCase(['4'], ['16'])],
        hidden: [_numericCase(['7'], ['49']), _numericCase(['0'], ['0'])],
      );

      expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
      expect(result.passedCases, 3);
      expect(result.totalCases, 3);
      expect(result.firstFailure, isNull);
      expect(result.isSolved, isTrue);
    });

    test('two checks of the same program against the same cases agree', () {
      final cases = [_numericCase(['4'], ['16'])];
      final first = _check(_square, visible: cases);
      final second = _check(_square, visible: cases);

      expect(first, second);
    });
  });

  group('BehaviourChecker hidden cases', () {
    test('a program that writes the visible answer passes the visible and fails a hidden one', () {
      final result = _check(
        _impostor,
        visible: [_numericCase(['4'], ['16'])],
        hidden: [_numericCase(['7'], ['49'])],
      );

      expect(result.outcome, ExerciseCheckOutcome.caseFailed);
      expect(result.passedCases, 1);
      expect(result.totalCases, 2);
      expect(result.firstFailure?.isHidden, isTrue);
      expect(result.firstFailure?.inputs, ['7']);
      expect(result.firstFailure?.expectedOutputs, ['49']);
      expect(result.firstFailure?.actualOutputs, ['16']);
    });
  });

  group('BehaviourChecker anomalous endings', () {
    test('a program that does not parse is a named result, not an exception', () {
      final result = _check(_doesNotParse, visible: [_numericCase(['4'], ['16'])]);

      expect(result.outcome, ExerciseCheckOutcome.programDidNotParse);
      expect(result.passedCases, 0);
      expect(result.totalCases, 1);
    });

    test('a program halted at run time is a named result', () {
      final result = _check(_dividesByZero, visible: [_numericCase(['4'], ['0'])]);

      expect(result.outcome, ExerciseCheckOutcome.programHalted);
    });

    test('a program that never ends reaches the step limit instead of hanging', () {
      final result = _check(
        _neverEnds,
        visible: [_numericCase(const [], ['0'])],
        stepLimit: 200,
      );

      expect(result.outcome, ExerciseCheckOutcome.stepLimitReached);
    });

    test('an input script shorter than the program asks for is a named result', () {
      final result = _check(_readsTwice, visible: [_numericCase(['4'], ['10'])]);

      expect(result.outcome, ExerciseCheckOutcome.inputScriptExhausted);
    });
  });

  group('BehaviourChecker edge cases', () {
    test('a case with no inputs runs a program that reads nothing', () {
      final result = _check(
        _writesNothing,
        visible: [_numericCase(const [], const [])],
      );

      expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
    });

    test('a program that writes nothing fails a case that expects a line', () {
      final result = _check(
        _writesNothing,
        visible: [_numericCase(const [], ['1'])],
      );

      expect(result.outcome, ExerciseCheckOutcome.caseFailed);
      expect(result.firstFailure?.actualOutputs, isEmpty);
    });

    test('a program that writes more lines than expected fails', () {
      final result = _check(
        _square,
        visible: [_numericCase(['4'], const [])],
      );

      expect(result.outcome, ExerciseCheckOutcome.caseFailed);
    });

    test('an exercise with no cases at all passes vacuously', () {
      final result = _check(_square);

      expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
      expect(result.totalCases, 0);
    });

    test('the echo of the input is not compared: only program output is', () {
      final result = _check(
        _readsTwice,
        visible: [_numericCase(['4', '6'], ['10'])],
      );

      expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
    });
  });
}
