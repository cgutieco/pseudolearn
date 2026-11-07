import '../../domain/model/knowledge/exercise_case.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_verdict.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/route_answer_evaluator.dart';
import '../exercise/output_normalizer.dart';
import '../exercise/program_runner.dart';

final class DesignTestsEvaluator implements RouteAnswerEvaluator {
  final ProgramRunner _runner;
  final OutputNormalizer _normalizer;

  const DesignTestsEvaluator({
    required ProgramRunner runner,
    OutputNormalizer normalizer = const OutputNormalizer(),
  }) : _runner = runner,
       _normalizer = normalizer;

  @override
  RouteVerdict evaluate({
    required RouteExercise exercise,
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final evaluation = exercise.evaluation;
    if (evaluation is! DesignTestsEvaluation || answer is! CasesRouteAnswer) {
      return const RouteVerdict.failed(NoFeedback());
    }
    final cases = answer.cases;
    if (cases.length < evaluation.minimum || cases.length > evaluation.maximum) {
      return RouteVerdict.failed(
        WrongCountFeedback(minimum: evaluation.minimum, maximum: evaluation.maximum),
      );
    }
    final edition = (profileId, languageId);
    for (var index = 0; index < cases.length; index++) {
      final reference = _passes(evaluation.reference, cases[index], edition);
      if (!reference.$1) {
        return RouteVerdict.failed(
          ReferenceRejectsFeedback(caseIndex: index, referenceOutput: reference.$2),
        );
      }
    }
    final survivors = evaluation.mutants
        .where((mutant) => cases.every((entry) => _passes(mutant, entry, edition).$1))
        .length;
    if (survivors == 0) return const RouteVerdict.solved();
    return RouteVerdict.failed(SurvivorsFeedback(survivors));
  }

  (bool, List<String>) _passes(
    String code,
    ExerciseCase exerciseCase,
    (SyntaxProfileId, UiLanguageId) edition,
  ) {
    final run = _runner.run(
      sourceCode: code,
      profileId: edition.$1,
      languageId: edition.$2,
      inputs: exerciseCase.inputs,
    );
    final passes = run.anomaly == null &&
        _normalizer.matches(
          expected: exerciseCase.expectedOutputs,
          actual: run.outputs,
          kind: exerciseCase.expectedValueKind,
        );
    return (passes, run.outputs);
  }
}
