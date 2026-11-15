import '../../domain/model/execution/execution_step.dart';
import '../../domain/ports/execution_context.dart';
import '../../domain/ports/execution_reproduction.dart';
import '../../domain/ports/program_execution.dart';
import 'execution_state.dart';
import 'execution_status_from_step.dart';

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
  final reproduction = switch (execution) {
    final ExecutionReproduction value => value,
    _ => null,
  };
  return current.copyWith(
    status: executionStatusFromStep(step),
    currentStep: step,
    outputLines: lines,
    workingDirectory: switch (execution) {
      final ExecutionContext context => context.workingDirectory,
      _ => null,
    },
    recordedTape: reproduction?.recordedTape,
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
