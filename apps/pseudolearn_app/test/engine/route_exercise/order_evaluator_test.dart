import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/engine/exercise/behaviour_checker.dart';
import 'package:pseudolearn_app/engine/route_exercise/order_evaluator.dart';
import '../../fakes/native_test_engine.dart';
import '../../fakes/route_fixtures.dart';
import 'evaluator_support.dart';

void main() {
  final evaluator = OrderEvaluator(
    behaviour: BehaviourChecker(
      execution: nativeTestEngine.createProgramExecution(),
      analyzer: nativeTestEngine.analyzer,
    ),
  );

  group('steps', () {
    final evaluation = OrderStepsEvaluation(
      steps: [runsOf('b'), runsOf('a'), runsOf('c')],
      solution: const [1, 0, 2],
    );

    test('accepts the exact order', () {
      expect(verdictOf(evaluator, evaluation, const OrderRouteAnswer([1, 0, 2])).solved, isTrue);
    });

    test('marks the positions that are out of place', () {
      final verdict = verdictOf(evaluator, evaluation, const OrderRouteAnswer([0, 1, 2]));
      expect((verdict.feedback as MisplacedFeedback).elements, {0, 1});
    });

    test('a short answer leaves the rest out of place', () {
      final verdict = verdictOf(evaluator, evaluation, const OrderRouteAnswer([1]));
      expect((verdict.feedback as MisplacedFeedback).elements, {1, 2});
    });
  });

  group('program', () {
    final evaluation = OrderProgramEvaluation(
      head: 'Algoritmo Orden',
      tail: 'FinAlgoritmo',
      blocks: const ['Escribir 2;', 'Escribir 1;'],
      solution: const [1, 0],
      cases: [caseOf(const [], '1\n2')],
    );

    test('accepts the order that passes the cases', () {
      final verdict = verdictOf(evaluator, evaluation, const OrderRouteAnswer([1, 0]), kind: RouteExerciseKind.order);
      expect(verdict.solved, isTrue);
    });

    test('a wrong order reports the failing case', () {
      final verdict = verdictOf(evaluator, evaluation, const OrderRouteAnswer([0, 1]), kind: RouteExerciseKind.order);
      expect(verdict.solved, isFalse);
      expect(verdict.feedback, isA<CaseFailureFeedback>());
    });
  });
}
