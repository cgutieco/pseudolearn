import '../../domain/model/execution/effect_tape.dart';
import '../../domain/model/execution/execution_configuration.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/ports/execution_context.dart';
import '../../domain/ports/execution_reproduction.dart';
import '../../domain/ports/program_execution.dart';
import 'execution_state.dart';
import 'execution_status_from_step.dart';

ExecutionState stateAtStart(
  ExecutionState current,
  ExecutionStep initialStep,
  ProgramExecution execution, {
  required int runId,
  required ExecutionConfiguration configuration,
  EffectTape? replayTape,
}) => ExecutionState(
  status: ExecutionStatus.pausedAtStatement,
  currentStep: initialStep,
  outputLines: execution.outputLines,
  runId: runId,
  statementNumber: 0,
  isOutputPanelExpanded: current.isOutputPanelExpanded,
  userCollapsedOutput: current.userCollapsedOutput,
  isTraceVisible: current.isTraceVisible,
  isTasksVisible: current.isTasksVisible,
  observesVariables: current.observesVariables,
  isContinuous: current.isContinuous,
  configuration: configuration,
  recordedTape: replayTape,
);

ExecutionState stateAfterStep(
  ExecutionState current,
  ExecutionStep step,
  ProgramExecution execution,
) {
  final lines = execution.outputLines;
  final shouldAutoExpand =
      lines.isNotEmpty &&
      !current.isOutputPanelExpanded &&
      !current.userCollapsedOutput;
  final advanced = step.focusRevision != current.currentStep.focusRevision;
  final status = executionStatusFromStep(step);
  final reproduction = switch (execution) {
    final ExecutionReproduction value => value,
    _ => null,
  };
  return current.copyWith(
    status: status,
    currentStep: step,
    outputLines: lines,
    workingDirectory: switch (execution) {
      final ExecutionContext context => context.workingDirectory,
      _ => null,
    },
    recordedTape: _isMidRun(current, status)
        ? null
        : reproduction?.recordedTape,
    replayRejection: reproduction?.replayRejection,
    statementNumber: advanced
        ? current.statementNumber + 1
        : current.statementNumber,
    isOutputPanelExpanded: shouldAutoExpand
        ? true
        : current.isOutputPanelExpanded,
    haltMessage: step.haltReason,
  );
}

bool _isMidRun(ExecutionState current, ExecutionStatus status) =>
    current.isContinuous && status == ExecutionStatus.running;
