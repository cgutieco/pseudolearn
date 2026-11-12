import '../../domain/model/knowledge/expected_value_kind.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/route_answer_evaluator.dart';
import '../exercise/output_normalizer.dart';

final class PredictionEvaluator implements RouteAnswerEvaluator {
  final OutputNormalizer _normalizer;

  const PredictionEvaluator({this._normalizer = const OutputNormalizer()});

  @override
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final evaluation = exercise.evaluation;
    if (evaluation is! PredictEvaluation || answer is! TextRouteAnswer) {
      return const RouteVerdict.failed(NoFeedback());
    }
    final expected = _normalizer.normalize(evaluation.output.split('\n'));
    final given = _normalizer.normalize(answer.text.split('\n'));
    final matches = _normalizer.matches(
      expected: expected,
      actual: given,
      kind: ExpectedValueKind.numeric,
    );
    if (matches) return const RouteVerdict.solved();
    return RouteVerdict.failed(LineMismatchFeedback(_firstDifference(expected, given)));
  }

  int _firstDifference(List<String> expected, List<String> given) {
    for (var line = 0; line < expected.length; line++) {
      if (line >= given.length) return line;
      final same = _normalizer.matches(
        expected: [expected[line]],
        actual: [given[line]],
        kind: ExpectedValueKind.numeric,
      );
      if (!same) return line;
    }
    return expected.length;
  }
}
