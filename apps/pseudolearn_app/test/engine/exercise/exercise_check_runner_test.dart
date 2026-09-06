import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'package:pseudolearn_app/engine/exercise/behaviour_checker.dart';
import 'package:pseudolearn_app/engine/exercise/exercise_check_runner.dart';
import 'package:pseudolearn_app/engine/exercise/structural_assertion_checker.dart';

const String _withCountedLoop = '''
Algoritmo Suma
  Definir n Como Entero
  Definir i Como Entero
  Definir total Como Entero
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
  Definir n Como Entero
  Definir i Como Entero
  Definir total Como Entero
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
  final runner = ExerciseCheckRunner(
    behaviour: BehaviourChecker(
      execution: CoreProgramExecution(),
      analyzer: CoreProgramAnalyzer(),
    ),
    structure: StructuralAssertionChecker(),
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
    test('a program that passes the cases and meets the assertion is solved', () {
      final result = _check(_withCountedLoop, assertions: const [_usesCountedLoop]);

      expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
      expect(result.unmetAssertions, isEmpty);
      expect(result.isSolved, isTrue);
    });

    test('a program that passes the cases but not the assertion is not solved', () {
      final result = _check(_withConditionalLoop, assertions: const [_usesCountedLoop]);

      expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
      expect(result.unmetAssertions, [_usesCountedLoop]);
      expect(result.isSolved, isFalse);
    });

    test('an exercise without assertions is judged on behaviour alone', () {
      final result = _check(_withConditionalLoop);

      expect(result.unmetAssertions, isEmpty);
      expect(result.isSolved, isTrue);
    });
  });
}
