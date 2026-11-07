import 'package:flutter/material.dart';
import '../../../domain/model/route/route_answer.dart';
import '../../../domain/model/route/route_evaluation.dart';
import '../../../domain/model/route/route_exercise.dart';
import '../../../domain/model/route/route_verdict.dart';
import '../lesson_scope.dart';
import 'choice_answer_view.dart';
import 'design_answer_view.dart';
import 'inputs_answer_view.dart';
import 'order_answer_view.dart';
import 'text_answer_view.dart';
import 'trace_answer_view.dart';

final class AnswerPanel extends StatelessWidget {
  final RouteExercise exercise;
  final RouteVerdict? verdict;
  final LessonScope scope;
  final ValueChanged<RouteAnswer> onSubmit;

  const AnswerPanel({
    super.key,
    required this.exercise,
    required this.verdict,
    required this.scope,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final evaluation = exercise.evaluation;
    return switch (evaluation) {
      PredictEvaluation() => TextAnswerView(onSubmit: onSubmit),
      TraceEvaluation() => TraceAnswerView(evaluation: evaluation, verdict: verdict, onSubmit: onSubmit),
      OrderStepsEvaluation() => OrderAnswerView.steps(evaluation: evaluation, scope: scope, onSubmit: onSubmit),
      OrderProgramEvaluation() => OrderAnswerView.program(evaluation: evaluation, scope: scope, onSubmit: onSubmit),
      BreakEvaluation(:final reads) => InputsAnswerView(reads: reads, onSubmit: onSubmit),
      DesignTestsEvaluation() => DesignAnswerView(evaluation: evaluation, onSubmit: onSubmit),
      ClassifyEvaluation() => ClassifyAnswerView(evaluation: evaluation, verdict: verdict, scope: scope, onSubmit: onSubmit),
      ChoiceEvaluation() => ChoiceAnswerView(evaluation: evaluation, scope: scope, onSubmit: onSubmit),
      CasesEvaluation() => const SizedBox.shrink(),
    };
  }
}
