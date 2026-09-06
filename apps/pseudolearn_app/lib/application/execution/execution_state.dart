import 'package:equatable/equatable.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import 'step_batch_runner.dart';

enum ExecutionStatus {
  idle,
  running,
  pausedAtStatement,
  pausedAwaitingInput,
  stepLimitReached,
  haltedWithError,
  finishedSuccess,
}

final class ExecutionState extends Equatable {
  final ExecutionStatus status;
  final ExecutionStep currentStep;
  final List<OutputLine> outputLines;
  final int runId;
  final int statementNumber;
  final bool isOutputStale;
  final bool isOutputPanelExpanded;
  final bool userCollapsedOutput;
  final bool isStatusBannerDismissed;
  final String? haltMessage;

  const ExecutionState({
    required this.status,
    required this.currentStep,
    required this.outputLines,
    this.runId = 0,
    this.statementNumber = 0,
    this.isOutputStale = false,
    this.isOutputPanelExpanded = false,
    this.userCollapsedOutput = false,
    this.isStatusBannerDismissed = false,
    this.haltMessage,
  });

  const ExecutionState.initial()
      : status = ExecutionStatus.idle,
        currentStep = const ExecutionStep(
          stepNumber: 0,
          scopeName: 'global',
          scopeDepth: 1,
        ),
        outputLines = const [],
        runId = 0,
        statementNumber = 0,
        isOutputStale = false,
        isOutputPanelExpanded = false,
        userCollapsedOutput = false,
        isStatusBannerDismissed = false,
        haltMessage = null;

  bool get isNearStepLimit =>
      currentStep.stepNumber >= StepBatchRunner.warningStepThreshold;

  bool get canStart =>
      status != ExecutionStatus.running &&
      status != ExecutionStatus.pausedAwaitingInput;

  bool get isInFlight =>
      status == ExecutionStatus.running ||
      status == ExecutionStatus.pausedAtStatement ||
      status == ExecutionStatus.pausedAwaitingInput;

  bool get isPaused =>
      status == ExecutionStatus.pausedAtStatement ||
      status == ExecutionStatus.pausedAwaitingInput;

  bool get canStepOverBlock => currentStep.focus?.isDecision ?? false;

  bool get canStepOutOfBlock => currentStep.blockPosition.hasEnclosingBlock;

  ExecutionState copyWith({
    ExecutionStatus? status,
    ExecutionStep? currentStep,
    List<OutputLine>? outputLines,
    int? runId,
    int? statementNumber,
    bool? isOutputStale,
    bool? isOutputPanelExpanded,
    bool? userCollapsedOutput,
    bool? isStatusBannerDismissed,
    String? haltMessage,
  }) {
    return ExecutionState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      outputLines: outputLines ?? this.outputLines,
      runId: runId ?? this.runId,
      statementNumber: statementNumber ?? this.statementNumber,
      isOutputStale: isOutputStale ?? this.isOutputStale,
      isOutputPanelExpanded: isOutputPanelExpanded ?? this.isOutputPanelExpanded,
      userCollapsedOutput: userCollapsedOutput ?? this.userCollapsedOutput,
      isStatusBannerDismissed:
          isStatusBannerDismissed ?? this.isStatusBannerDismissed,
      haltMessage: haltMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStep,
        outputLines,
        runId,
        statementNumber,
        isOutputStale,
        isOutputPanelExpanded,
        userCollapsedOutput,
        isStatusBannerDismissed,
        haltMessage,
      ];
}
