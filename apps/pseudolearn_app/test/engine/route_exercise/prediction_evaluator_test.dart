import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/engine/route_exercise/prediction_evaluator.dart';
import 'evaluator_support.dart';

void main() {
  const evaluator = PredictionEvaluator();
  const evaluation = PredictEvaluation('10 / 4\n2.5');

  test('accepts the exact output with loose spacing and numbers', () {
    final verdict = verdictOf(evaluator, evaluation, const TextRouteAnswer(' 10  /  4\n2.50\n\n'));
    expect(verdict.solved, isTrue);
  });

  test('reports the first line that differs', () {
    final verdict = verdictOf(evaluator, evaluation, const TextRouteAnswer('10 / 4\n2'));
    expect(verdict.solved, isFalse);
    expect((verdict.feedback as LineMismatchFeedback).line, 1);
  });

  test('a missing line is reported at its position', () {
    final verdict = verdictOf(evaluator, evaluation, const TextRouteAnswer('10 / 4'));
    expect((verdict.feedback as LineMismatchFeedback).line, 1);
  });

  test('an answer of the wrong type is never accepted', () {
    final verdict = verdictOf(evaluator, evaluation, const ChoiceRouteAnswer(0));
    expect(verdict.solved, isFalse);
    expect(verdict.feedback, isA<NoFeedback>());
  });
}
