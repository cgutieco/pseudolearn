import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/engine/route_exercise/classify_evaluator.dart';
import '../../fakes/route_fixtures.dart';
import 'evaluator_support.dart';

void main() {
  const evaluator = ClassifyEvaluator();
  final evaluation = ClassifyEvaluation(
    categories: const ['Entero', 'Cadena'],
    elements: [
      ClassifiedEntry(runs: runsOf('23'), category: 0),
      ClassifiedEntry(runs: runsOf('"23"'), category: 1),
    ],
  );

  test('accepts every element in its category', () {
    expect(verdictOf(evaluator, evaluation, const AssignmentRouteAnswer({0: 0, 1: 1})).solved, isTrue);
  });

  test('reports misplaced and missing elements', () {
    final verdict = verdictOf(evaluator, evaluation, const AssignmentRouteAnswer({0: 1}));
    expect((verdict.feedback as MisplacedFeedback).elements, {0, 1});
  });

  test('an empty classification is not accepted', () {
    expect(verdictOf(evaluator, evaluation, const AssignmentRouteAnswer({})).solved, isFalse);
  });
}
