import 'package:pseudolearn_app/engine/rust/rust_exercise_checker.dart';
import 'package:pseudolearn_app/engine/rust/rust_structural_assertion_checker.dart';
import '../../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/exercise/behaviour_checker.dart';

const String _withCountedLoop = '''
Algoritmo Suma
  Definir Mutable n Como Entero <- 0
  Definir i Como Entero <- 0
  Definir Mutable total Como Entero <- 0
  Leer n
  total <- 0
  Para i <- 1 Hasta n Con Paso 1 Hacer
    total <- total + i
  FinPara
  Escribir total
FinAlgoritmo
''';

const String _withConditionalLoop = '''
Algoritmo Suma
  Definir Mutable n Como Entero <- 0
  Definir Mutable i Como Entero <- 0
  Definir Mutable total Como Entero <- 0
  Leer n
  total <- 0
  i <- 1
  Mientras i <= n Hacer
    total <- total + i
    i <- i + 1
  FinMientras
  Escribir total
FinAlgoritmo
''';

const _usesCountedLoop = ContainsConstructAssertion(
  requirement: 'El enunciado pedia resolverlo con un bucle contado.',
  construct: AstConstruct.countedLoop,
);

const _cases = [
  ExerciseCase(
    inputs: ['4'],
    expectedOutputs: ['10'],
    expectedValueKind: ExpectedValueKind.numeric,
  ),
];

ExerciseCheckResult _check(
  String sourceCode, {
  List<StructuralAssertion> assertions = const [],
}) {
  final runner = RustExerciseChecker(
    behaviour: BehaviourChecker(
      execution: nativeTestEngine.createProgramExecution(),
      analyzer: nativeTestEngine.analyzer,
    ),
    structure: RustStructuralAssertionChecker(testTransport),
  );
  return runner.check(
    sourceCode: sourceCode,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
    visibleCases: _cases,
    hiddenCases: const [],
    assertions: assertions,
  );
}

void main() {
  group('ExerciseCheckRunner', () {
    test(
      'a program that passes the cases and meets the assertion is solved',
      () {
        final result = _check(
          _withCountedLoop,
          assertions: const [_usesCountedLoop],
        );

        expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
        expect(result.unmetAssertions, isEmpty);
        expect(result.isSolved, isTrue);
      },
    );

    test(
      'a program that passes the cases but not the assertion is not solved',
      () {
        final result = _check(
          _withConditionalLoop,
          assertions: const [_usesCountedLoop],
        );

        expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
        expect(result.unmetAssertions, [_usesCountedLoop]);
        expect(result.isSolved, isFalse);
      },
    );

    test('an exercise without assertions is judged on behaviour alone', () {
      final result = _check(_withConditionalLoop);

      expect(result.unmetAssertions, isEmpty);
      expect(result.isSolved, isTrue);
    });
  });
}
