import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/route_answer_evaluator.dart';

final class ChoiceEvaluator implements RouteAnswerEvaluator {
  const ChoiceEvaluator();

  @override
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final evaluation = exercise.evaluation;
    if (evaluation is ChoiceEvaluation && answer is ChoiceRouteAnswer) {
      return answer.option == evaluation.correctIndex
          ? const RouteVerdict.solved()
          : RouteVerdict.failed(MisplacedFeedback({answer.option}));
    }
    return const RouteVerdict.failed(NoFeedback());
  }
}
