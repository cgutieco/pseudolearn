import 'package:equatable/equatable.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/simulated_scenario.dart';
import 'step_batch_runner.dart';

enum ExecutionStatus {
  idle,
  running,
  pausedAtStatement,
  pausedAwaitingInput,
  pausedAwaitingEffect,
  stepLimitReached,
  uiSafetyLimitReached,
  haltedWithError,
  finishedSuccess,
}

enum ExecutionViewAction {
  toggleOutputPanel,
  dismissStatusBanner,
  selectScenario,
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
  final SimulatedScenario simulatedScenario;

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
    this.simulatedScenario = SimulatedScenario.noHost,
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
      haltMessage = null,
      simulatedScenario = SimulatedScenario.noHost;

  bool get isNearStepLimit =>
      currentStep.stepNumber >= StepBatchRunner.warningUiAdvanceThreshold;

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

  ExecutionState applyViewAction(
    ExecutionViewAction action, {
    SimulatedScenario? scenario,
  }) {
    switch (action) {
      case ExecutionViewAction.toggleOutputPanel:
        final expanded = !isOutputPanelExpanded;
        return copyWith(
          isOutputPanelExpanded: expanded,
          userCollapsedOutput: !expanded,
        );
      case ExecutionViewAction.dismissStatusBanner:
        return isStatusBannerDismissed
            ? this
            : copyWith(isStatusBannerDismissed: true);
      case ExecutionViewAction.selectScenario:
        return _selectedScenario(scenario);
    }
  }

  ExecutionState _selectedScenario(SimulatedScenario? scenario) {
    if (scenario == null || isInFlight || simulatedScenario == scenario) {
      return this;
    }
    return copyWith(simulatedScenario: scenario);
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
    bool? isStatusBannerDismissed,
    String? haltMessage,
    SimulatedScenario? simulatedScenario,
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
      isStatusBannerDismissed:
          isStatusBannerDismissed ?? this.isStatusBannerDismissed,
      haltMessage: haltMessage,
      simulatedScenario: simulatedScenario ?? this.simulatedScenario,
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
    simulatedScenario,
  ];
}
