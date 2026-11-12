import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/route_answer_evaluator.dart';

final class ClassifyEvaluator implements RouteAnswerEvaluator {
  const ClassifyEvaluator();

  @override
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final evaluation = exercise.evaluation;
    if (evaluation is! ClassifyEvaluation || answer is! AssignmentRouteAnswer) {
      return const RouteVerdict.failed(NoFeedback());
    }
    final wrong = <int>{};
    for (var index = 0; index < evaluation.elements.length; index++) {
      final expected = evaluation.elements[index].category;
      if (answer.categoryByElement[index] != expected) wrong.add(index);
    }
    if (wrong.isEmpty) return const RouteVerdict.solved();
    return RouteVerdict.failed(MisplacedFeedback(wrong));
  }
}
