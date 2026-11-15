import '../../domain/model/knowledge/exercise_case.dart';
import '../../domain/model/knowledge/exercise_case_failure.dart';
import '../../domain/model/knowledge/exercise_check_outcome.dart';
import '../../domain/model/knowledge/exercise_check_result.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/program_execution.dart';
import 'output_normalizer.dart';
import 'program_run.dart';
import 'program_runner.dart';

final class BehaviourChecker {
  static const int defaultStepLimit = ProgramRunner.defaultStepLimit;

  final ProgramRunner _runner;
  final OutputNormalizer _normalizer;

  BehaviourChecker({
    required ProgramExecution execution,
    required ProgramAnalyzer analyzer,
    OutputNormalizer normalizer = const OutputNormalizer(),
    int stepLimit = defaultStepLimit,
  }) : _runner = ProgramRunner(
         execution: execution,
         analyzer: analyzer,
         normalizer: normalizer,
         stepLimit: stepLimit,
       ),
       _normalizer = normalizer;

  ExerciseCheckResult checkBehaviour({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<ExerciseCase> visibleCases,
    required List<ExerciseCase> hiddenCases,
  }) {
    final cases = [...visibleCases, ...hiddenCases];
    final parses = _runner.parses(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    if (!parses) {
      return ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.programDidNotParse,
        passedCases: 0,
        totalCases: cases.length,
      );
    }
    return _checkCases(
      cases: cases,
      visibleCount: visibleCases.length,
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
  }

  ExerciseCheckResult _checkCases({
    required List<ExerciseCase> cases,
    required int visibleCount,
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    for (var index = 0; index < cases.length; index++) {
      final run = _run(
        sourceCode: sourceCode,
        profileId: profileId,
        languageId: languageId,
        inputs: cases[index].inputs,
      );
      final outcome = _outcomeOf(run, cases[index]);
      if (outcome == null) continue;
      return ExerciseCheckResult(
        outcome: outcome,
        passedCases: index,
        totalCases: cases.length,
        firstFailure: ExerciseCaseFailure(
          caseIndex: index,
          isHidden: index >= visibleCount,
          inputs: cases[index].inputs,
          expectedOutputs: cases[index].expectedOutputs,
          actualOutputs: run.outputs,
        ),
      );
    }
    return ExerciseCheckResult(
      outcome: ExerciseCheckOutcome.allCasesPassed,
      passedCases: cases.length,
      totalCases: cases.length,
    );
  }

  ExerciseCheckOutcome? _outcomeOf(ProgramRun run, ExerciseCase exerciseCase) {
    if (run.anomaly != null) return run.anomaly;
    final passes = _normalizer.matches(
      expected: exerciseCase.expectedOutputs,
      actual: run.outputs,
      kind: exerciseCase.expectedValueKind,
    );
    return passes ? null : ExerciseCheckOutcome.caseFailed;
  }

  ProgramRun _run({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<String> inputs,
  }) => _runner.run(
    sourceCode: sourceCode,
    profileId: profileId,
    languageId: languageId,
    inputs: inputs,
  );
}
