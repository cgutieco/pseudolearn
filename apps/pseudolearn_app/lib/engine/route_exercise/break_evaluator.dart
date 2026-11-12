import '../../domain/model/knowledge/expected_value_kind.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/route_answer_evaluator.dart';
import '../exercise/output_normalizer.dart';
import '../exercise/program_run.dart';
import '../exercise/program_runner.dart';

final class BreakEvaluator implements RouteAnswerEvaluator {
  final ProgramRunner _runner;
  final OutputNormalizer _normalizer;

  const BreakEvaluator({
    required this._runner,
    this._normalizer = const OutputNormalizer(),
  });

  @override
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final evaluation = exercise.evaluation;
    if (evaluation is! BreakEvaluation || answer is! InputsRouteAnswer) {
      return const RouteVerdict.failed(NoFeedback());
    }
    ProgramRun run(String code) => _runner.run(
      sourceCode: code,
      profileId: profileId,
      languageId: languageId,
      inputs: answer.inputs,
    );
    final reference = run(evaluation.reference);
    if (reference.anomaly != null) {
      return RouteVerdict.failed(
        ReferenceRejectsFeedback(caseIndex: 0, referenceOutput: reference.outputs),
      );
    }
    final defective = run(evaluation.defective);
    if (defective.anomaly != null || !_sameOutput(reference, defective)) {
      return const RouteVerdict.solved();
    }
    return RouteVerdict.failed(
      UnbrokenFeedback(
        defectiveOutput: defective.outputs,
        referenceOutput: reference.outputs,
      ),
    );
  }

  bool _sameOutput(ProgramRun reference, ProgramRun defective) =>
      _normalizer.matches(
        expected: reference.outputs,
        actual: defective.outputs,
        kind: ExpectedValueKind.numeric,
      );
}
