import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/engine/exercise/program_runner.dart';
import 'package:pseudolearn_app/engine/route_exercise/design_tests_evaluator.dart';
import '../../fakes/native_test_engine.dart';
import '../../fakes/route_fixtures.dart';
import 'evaluator_support.dart';

void main() {
  final evaluator = DesignTestsEvaluator(
    runner: ProgramRunner(
      execution: nativeTestEngine.createProgramExecution(),
      analyzer: nativeTestEngine.analyzer,
    ),
  );
  const evaluation = DesignTestsEvaluation(
    reference: sumProgram,
    mutants: [productProgram, doubleProgram],
    reads: 2,
    minimum: 1,
    maximum: 3,
  );

  RouteVerdict designed(List<(List<String>, String)> cases) => verdictOf(
    evaluator,
    evaluation,
    CasesRouteAnswer([for (final (inputs, expected) in cases) caseOf(inputs, expected)]),
    kind: RouteExerciseKind.designTests,
  );

  test('cases that the reference passes and that catch every mutant win', () {
    expect(designed([(['1', '3'], '4')]).solved, isTrue);
  });

  test('a case the reference fails is reported with its output', () {
    final verdict = designed([(['1', '3'], '5')]);
    expect((verdict.feedback as ReferenceRejectsFeedback).referenceOutput, ['4']);
  });

  test('cases that let a mutant through report the survivors', () {
    final verdict = designed([(['2', '2'], '4')]);
    expect((verdict.feedback as SurvivorsFeedback).survivors, 2);
  });

  test('too many or too few cases are rejected before running', () {
    expect(designed([]).feedback, isA<WrongCountFeedback>());
    expect(
      designed([(['1', '1'], '2'), (['1', '2'], '3'), (['2', '2'], '4'), (['3', '3'], '6')]).feedback,
      isA<WrongCountFeedback>(),
    );
  });
}
