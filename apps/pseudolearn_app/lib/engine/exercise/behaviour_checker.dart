import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
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

final class BehaviourChecker {
  static const int defaultStepLimit = 10000;

  final ProgramExecution _execution;
  final ProgramAnalyzer _analyzer;
  final OutputNormalizer _normalizer;
  final int _stepLimit;

  BehaviourChecker({
    required ProgramExecution execution,
    required ProgramAnalyzer analyzer,
    OutputNormalizer normalizer = const OutputNormalizer(),
    int stepLimit = defaultStepLimit,
  })  : _execution = execution,
        _analyzer = analyzer,
        _normalizer = normalizer,
        _stepLimit = stepLimit;

  ExerciseCheckResult checkBehaviour({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<ExerciseCase> visibleCases,
    required List<ExerciseCase> hiddenCases,
  }) {
    final cases = [...visibleCases, ...hiddenCases];
    final report = _analyzer.analyze(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    if (report.hasErrors || !report.isExecutable) {
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
  }) {
    var step = _execution.startExecution(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    var consumedInputs = 0;
    var takenSteps = 0;
    while (!step.isFinished) {
      final anomaly = _anomalyOf(
        step: step,
        consumedInputs: consumedInputs,
        availableInputs: inputs.length,
        takenSteps: takenSteps,
      );
      if (anomaly != null) return _stopWith(anomaly);
      if (step.isAwaitingInput) {
        step = _execution.provideInput(inputs[consumedInputs]);
        consumedInputs++;
      } else {
        step = _execution.step();
      }
      takenSteps++;
    }
    return _stopWith(null);
  }

  ExerciseCheckOutcome? _anomalyOf({
    required ExecutionStep step,
    required int consumedInputs,
    required int availableInputs,
    required int takenSteps,
  }) {
    if (step.isHalted) return ExerciseCheckOutcome.programHalted;
    if (takenSteps >= _stepLimit) return ExerciseCheckOutcome.stepLimitReached;
    if (step.isAwaitingInput && consumedInputs >= availableInputs) {
      return ExerciseCheckOutcome.inputScriptExhausted;
    }
    return null;
  }

  ProgramRun _stopWith(ExerciseCheckOutcome? anomaly) {
    final outputs = _normalizer.normalize(_programOutputs());
    _execution.stop();
    return ProgramRun(anomaly: anomaly, outputs: outputs);
  }

  List<String> _programOutputs() {
    final lines = <String>[];
    for (final line in _execution.outputLines) {
      if (line.kind == OutputLineKind.programOutput) {
        lines.add(line.text);
      }
    }
    return lines;
  }
}
