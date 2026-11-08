import '../../domain/model/execution/execution_configuration.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/knowledge/exercise_check_outcome.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/program_execution.dart';
import 'output_normalizer.dart';
import 'program_run.dart';

final class ProgramRunner {
  static const int defaultStepLimit = 10000;

  final ProgramExecution _execution;
  final ProgramAnalyzer _analyzer;
  final OutputNormalizer _normalizer;
  final int _stepLimit;

  ProgramRunner({
    required ProgramExecution execution,
    required ProgramAnalyzer analyzer,
    OutputNormalizer normalizer = const OutputNormalizer(),
    int stepLimit = defaultStepLimit,
  }) : _execution = execution,
       _analyzer = analyzer,
       _normalizer = normalizer,
       _stepLimit = stepLimit;

  bool parses({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final report = _analyzer.analyze(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    return !report.hasErrors && report.isExecutable;
  }

  ProgramRun run({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required List<String> inputs,
    List<String> arguments = const [],
  }) {
    var step = _execution.startExecution(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      configuration: ExecutionConfiguration(arguments: arguments),
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
      final request = step.inputWait;
      if (step.isAwaitingInput && request == null) {
        return _stopWith(ExerciseCheckOutcome.programHalted);
      }
      if (step.isAwaitingInput && request != null) {
        step = _execution.provideInput(request, inputs[consumedInputs]);
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
    final outputs = _normalizer.normalize(
      _linesOf(OutputLineKind.programOutput),
    );
    final errors = _linesOf(OutputLineKind.programError);
    _execution.stop();
    return ProgramRun(anomaly: anomaly, outputs: outputs, errors: errors);
  }

  List<String> _linesOf(OutputLineKind kind) {
    final lines = <String>[];
    for (final line in _execution.outputLines) {
      if (line.kind == kind) lines.add(line.text);
    }
    return lines;
  }
}
