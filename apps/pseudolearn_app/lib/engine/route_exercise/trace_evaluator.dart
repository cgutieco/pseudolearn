import '../../domain/model/knowledge/expected_value_kind.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/route_answer_evaluator.dart';
import '../exercise/output_normalizer.dart';

final class TraceEvaluator implements RouteAnswerEvaluator {
  final OutputNormalizer _normalizer;

  const TraceEvaluator({this._normalizer = const OutputNormalizer()});

  @override
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final evaluation = exercise.evaluation;
    if (evaluation is! TraceEvaluation || answer is! CellsRouteAnswer) {
      return const RouteVerdict.failed(NoFeedback());
    }
    final wrong = <(int, int)>{};
    for (var row = 0; row < evaluation.rows.length; row++) {
      final cells = evaluation.rows[row].cells;
      for (var column = 0; column < cells.length; column++) {
        if (!cells[column].editable) continue;
        final given = answer.cells[(row, column)] ?? '';
        if (!_same(cells[column].value, given)) wrong.add((row, column));
      }
    }
    if (wrong.isEmpty) return const RouteVerdict.solved();
    return RouteVerdict.failed(WrongCellsFeedback(wrong));
  }

  bool _same(String expected, String given) => _normalizer.matches(
    expected: [expected],
    actual: [given],
    kind: ExpectedValueKind.numeric,
  );
}
