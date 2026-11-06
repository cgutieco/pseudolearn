import '../../domain/model/execution/effect_tape.dart';
import '../../domain/model/execution/replay_rejection.dart';
import 'package:equatable/equatable.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/execution_configuration.dart';

enum ExecutionStatus {
  idle,
  running,
  pausedAtStatement,
  pausedAwaitingInput,
  pausedAwaitingEffect,
  stepLimitReached,
  uiSafetyLimitReached,
  haltedWithError,
  cancelledByHost,
  finishedSuccess,
}

enum ExecutionViewAction { toggleOutputPanel }

final class ExecutionState extends Equatable {
  final ExecutionStatus status;
  final ExecutionStep currentStep;
  final List<OutputLine> outputLines;
  final int runId;
  final int statementNumber;
  final bool isOutputStale;
  final bool isOutputPanelExpanded;
  final bool userCollapsedOutput;
  final String? haltMessage;
  final String? workingDirectory;
  final EffectTape? recordedTape;
  final ReplayRejection? replayRejection;
  final ExecutionConfiguration configuration;

  const ExecutionState({
    required this.status,
    required this.currentStep,
    required this.outputLines,
    this.runId = 0,
    this.statementNumber = 0,
    this.isOutputStale = false,
    this.isOutputPanelExpanded = false,
    this.userCollapsedOutput = false,
    this.haltMessage,
    this.workingDirectory,
    this.recordedTape,
    this.replayRejection,
    this.configuration = const ExecutionConfiguration(),
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
      haltMessage = null,
      workingDirectory = null,
      recordedTape = null,
      replayRejection = null,
      configuration = const ExecutionConfiguration();

  bool get canStart =>
      status != ExecutionStatus.running &&
      status != ExecutionStatus.pausedAwaitingInput &&
      status != ExecutionStatus.pausedAwaitingEffect;

  bool get isInFlight =>
      status == ExecutionStatus.running ||
      status == ExecutionStatus.pausedAtStatement ||
      status == ExecutionStatus.pausedAwaitingInput ||
      status == ExecutionStatus.pausedAwaitingEffect;

  bool get isPaused =>
      status == ExecutionStatus.pausedAtStatement ||
      status == ExecutionStatus.pausedAwaitingInput;

  bool get canStepOverBlock => currentStep.focus?.isDecision ?? false;

  bool get canStepOutOfBlock => currentStep.blockPosition.hasEnclosingBlock;

  ExecutionState applyViewAction(ExecutionViewAction action) {
    switch (action) {
      case ExecutionViewAction.toggleOutputPanel:
        final expanded = !isOutputPanelExpanded;
        return copyWith(
          isOutputPanelExpanded: expanded,
          userCollapsedOutput: !expanded,
        );
    }
  }

  ExecutionState copyWith({
    ExecutionStatus? status,
    ExecutionStep? currentStep,
    List<OutputLine>? outputLines,
    int? runId,
    int? statementNumber,
    bool? isOutputStale,
    bool? isOutputPanelExpanded,
    bool? userCollapsedOutput,
    String? haltMessage,
    String? workingDirectory,
    EffectTape? recordedTape,
    ReplayRejection? replayRejection,
    ExecutionConfiguration? configuration,
  }) {
    return ExecutionState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      outputLines: outputLines ?? this.outputLines,
      runId: runId ?? this.runId,
      statementNumber: statementNumber ?? this.statementNumber,
      isOutputStale: isOutputStale ?? this.isOutputStale,
      isOutputPanelExpanded:
          isOutputPanelExpanded ?? this.isOutputPanelExpanded,
      userCollapsedOutput: userCollapsedOutput ?? this.userCollapsedOutput,
      haltMessage: haltMessage,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      recordedTape: recordedTape ?? this.recordedTape,
      replayRejection: replayRejection,
      configuration: configuration ?? this.configuration,
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
    haltMessage,
    workingDirectory,
    recordedTape,
    replayRejection,
    configuration,
  ];
}
