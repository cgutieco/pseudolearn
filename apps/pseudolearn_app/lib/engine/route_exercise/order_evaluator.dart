import '../../domain/model/knowledge/exercise_check_outcome.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/route_answer_evaluator.dart';
import '../exercise/behaviour_checker.dart';

final class OrderEvaluator implements RouteAnswerEvaluator {
  final BehaviourChecker _behaviour;

  const OrderEvaluator({required BehaviourChecker behaviour})
    : _behaviour = behaviour;

  @override
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final evaluation = exercise.evaluation;
    if (answer is! OrderRouteAnswer) {
      return const RouteVerdict.failed(NoFeedback());
    }
    return switch (evaluation) {
      OrderStepsEvaluation(:final solution) => _steps(solution, answer.order),
      OrderProgramEvaluation() => _program(evaluation, answer.order, (
        profileId,
        languageId,
      )),
      _ => const RouteVerdict.failed(NoFeedback()),
    };
  }

  RouteVerdict _steps(List<int> solution, List<int> order) {
    final wrong = <int>{};
    for (var position = 0; position < solution.length; position++) {
      final given = position < order.length ? order[position] : -1;
      if (given != solution[position]) wrong.add(position);
    }
    if (wrong.isEmpty) return const RouteVerdict.solved();
    return RouteVerdict.failed(MisplacedFeedback(wrong));
  }

  RouteVerdict _program(
    OrderProgramEvaluation evaluation,
    List<int> order,
    (SyntaxProfileId, UiLanguageId) edition,
  ) {
    final lines = [
      evaluation.head,
      for (final index in order) evaluation.blocks[index],
      evaluation.tail,
    ];
    final result = _behaviour.checkBehaviour(
      sourceCode: '${lines.join('\n')}\n',
      profileId: edition.$1,
      languageId: edition.$2,
      visibleCases: evaluation.cases,
      hiddenCases: const [],
    );
    if (result.outcome == ExerciseCheckOutcome.allCasesPassed) {
      return const RouteVerdict.solved();
    }
    return RouteVerdict.failed(
      CaseFailureFeedback(outcome: result.outcome, failure: result.firstFailure),
    );
  }
}
