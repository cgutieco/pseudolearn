import '../../domain/model/execution/effect_tape.dart';
import '../../domain/model/execution/replay_rejection.dart';
import 'package:equatable/equatable.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/execution_configuration.dart';
import 'execution_view_action.dart';

export 'execution_view_action.dart';

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

final class ExecutionState extends Equatable {
  final ExecutionStatus status;
  final ExecutionStep currentStep;
  final List<OutputLine> outputLines;
  final int runId;
  final int statementNumber;
  final bool isOutputStale;
  final bool isOutputPanelExpanded;
  final bool userCollapsedOutput;
  final bool isTraceVisible;
  final bool isTasksVisible;
  final bool observesVariables;
  final bool isContinuous;
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
    this.isTraceVisible = false,
    this.isTasksVisible = false,
    this.observesVariables = true,
    this.isContinuous = false,
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
      isTraceVisible = false,
      isTasksVisible = false,
      observesVariables = true,
      isContinuous = false,
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

  bool get isContinuousRun => isContinuous && isInFlight;

  ExecutionFocus? get followedFocus =>
      isContinuousRun && status != ExecutionStatus.pausedAwaitingInput
      ? null
      : currentStep.focus;

  bool get canStepOverBlock => currentStep.focus?.isDecision ?? false;

  bool get canStepOutOfBlock => currentStep.blockPosition.hasEnclosingBlock;

  bool canAdvanceTask(int taskId) {
    for (final task in currentStep.taskContexts) {
      if (task.taskId != taskId) continue;
      return !task.status.isTerminal;
    }
    return false;
  }

  ExecutionState applyViewAction(ExecutionViewAction action) => switch (action) {
    ToggleOutputPanelViewAction() => copyWith(
      isOutputPanelExpanded: !isOutputPanelExpanded,
      userCollapsedOutput: isOutputPanelExpanded,
    ),
    ShowTraceViewAction() =>
        withVisibility(isTraceVisible: true, isTasksVisible: false),
    ShowTasksViewAction() =>
        withVisibility(isTraceVisible: false, isTasksVisible: true),
    ShowOtherTabViewAction() =>
        withVisibility(isTraceVisible: false, isTasksVisible: false),
    OpenDocumentViewAction(:final documentId) => const ExecutionState.initial()
        .copyWith(configuration: ExecutionConfiguration(documentId: documentId)),
  };

  ExecutionState withVisibility({
    bool? isTraceVisible,
    bool? isTasksVisible,
    bool? observesVariables,
    bool? isContinuous,
  }) => copyWith(
    isTraceVisible: isTraceVisible,
    isTasksVisible: isTasksVisible,
    observesVariables: observesVariables,
    isContinuous: isContinuous,
    haltMessage: haltMessage,
    replayRejection: replayRejection,
  );

  ExecutionState copyWith({
    ExecutionStatus? status,
    ExecutionStep? currentStep,
    List<OutputLine>? outputLines,
    int? runId,
    int? statementNumber,
    bool? isOutputStale,
    bool? isOutputPanelExpanded,
    bool? userCollapsedOutput,
    bool? isTraceVisible,
    bool? isTasksVisible,
    bool? observesVariables,
    bool? isContinuous,
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
      isTraceVisible: isTraceVisible ?? this.isTraceVisible,
      isTasksVisible: isTasksVisible ?? this.isTasksVisible,
      observesVariables: observesVariables ?? this.observesVariables,
      isContinuous: isContinuous ?? this.isContinuous,
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
    isTraceVisible,
    isTasksVisible,
    observesVariables,
    isContinuous,
    haltMessage,
    workingDirectory,
    recordedTape,
    replayRejection,
    configuration,
  ];
}
