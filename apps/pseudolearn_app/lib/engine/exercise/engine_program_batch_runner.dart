import '../../domain/model/knowledge/exercise_check_outcome.dart';
import '../../domain/model/program/program_run_report.dart';
import '../../domain/model/program/program_run_request.dart';
import '../../domain/ports/program_analyzer.dart';
import '../../domain/ports/program_batch_runner.dart';
import '../../domain/ports/program_execution.dart';
import 'program_runner.dart';

final class EngineProgramBatchRunner implements ProgramBatchRunner {
  final ProgramExecution Function() _createExecution;
  final ProgramAnalyzer _analyzer;

  const EngineProgramBatchRunner({
    required this._createExecution,
    required this._analyzer,
  });

  @override
  ProgramRunReport run(ProgramRunRequest request) {
    final runner = ProgramRunner(
      execution: _createExecution(),
      analyzer: _analyzer,
      stepLimit: request.boundedStepLimit,
    );
    final run = runner.run(
      sourceCode: request.sourceCode,
      profileId: request.profileId,
      languageId: request.languageId,
      inputs: request.inputs,
      arguments: request.arguments,
    );
    return ProgramRunReport(
      outcome: _outcomeOf(run.anomaly),
      outputs: run.outputs,
      errors: run.errors,
    );
  }

  ProgramRunOutcome _outcomeOf(ExerciseCheckOutcome? anomaly) =>
      switch (anomaly) {
        null => ProgramRunOutcome.finished,
        ExerciseCheckOutcome.stepLimitReached =>
          ProgramRunOutcome.stepLimitReached,
        ExerciseCheckOutcome.inputScriptExhausted =>
          ProgramRunOutcome.inputsExhausted,
        ExerciseCheckOutcome.programDidNotParse =>
          ProgramRunOutcome.notExecutable,
        _ => ProgramRunOutcome.halted,
      };
}
