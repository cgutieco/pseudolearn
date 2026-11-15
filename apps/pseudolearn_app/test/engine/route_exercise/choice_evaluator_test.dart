import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/engine/route_exercise/choice_evaluator.dart';
import '../../fakes/route_fixtures.dart';
import 'evaluator_support.dart';

void main() {
  const evaluator = ChoiceEvaluator();
  final evaluation = ChoiceEvaluation([
    ChoiceOption(runs: runsOf('a'), justification: runsOf('no'), correct: false),
    ChoiceOption(runs: runsOf('b'), justification: runsOf('sí'), correct: true),
  ]);

  test('accepts the correct option', () {
    expect(verdictOf(evaluator, evaluation, const ChoiceRouteAnswer(1)).solved, isTrue);
  });

  test('rejects another option and points at it', () {
    final verdict = verdictOf(evaluator, evaluation, const ChoiceRouteAnswer(0));
    expect(verdict.solved, isFalse);
    expect((verdict.feedback as MisplacedFeedback).elements, {0});
  });

  test('an option outside the list is rejected', () {
    expect(verdictOf(evaluator, evaluation, const ChoiceRouteAnswer(7)).solved, isFalse);
  });
}
