import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/engine/exercise/program_runner.dart';
import 'package:pseudolearn_app/engine/route_exercise/break_evaluator.dart';
import '../../fakes/native_test_engine.dart';
import 'evaluator_support.dart';

void main() {
  final evaluator = BreakEvaluator(
    runner: ProgramRunner(
      execution: nativeTestEngine.createProgramExecution(),
      analyzer: nativeTestEngine.analyzer,
    ),
  );
  const evaluation = BreakEvaluation(
    defective: doubleProgram,
    reference: sumProgram,
    reads: 2,
    cases: [],
  );

  RouteVerdict breaking(List<String> inputs) =>
      verdictOf(evaluator, evaluation, InputsRouteAnswer(inputs), kind: RouteExerciseKind.breakIt);

  test('an input where the outputs differ breaks the program', () {
    expect(breaking(const ['2', '3']).solved, isTrue);
  });

  test('an input where both agree reports both outputs', () {
    final verdict = breaking(const ['2', '2']);
    expect(verdict.solved, isFalse);
    expect((verdict.feedback as UnbrokenFeedback).referenceOutput, ['4']);
  });

  test('an input the reference cannot read is rejected', () {
    final verdict = breaking(const ['2']);
    expect(verdict.feedback, isA<ReferenceRejectsFeedback>());
  });
}
