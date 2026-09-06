import 'package:bloc/bloc.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_execution.dart';
import 'execution_state.dart';
import 'step_batch_runner.dart';
import 'step_pace.dart';
import 'step_settlement.dart';

final class ExecutionCubit extends Cubit<ExecutionState> {
  final ProgramExecution _execution;
  final StepBatchRunner _runner;
  bool _stopRequested = false;
  bool _hasStarted = false;
  int _runCounter = 0;
  StepSettlement _settlement = const StepSettlement.atAnyFocusChange();
  int _fromRevision = 0;

  ExecutionCubit({
    required ProgramExecution execution,
    StepBatchRunner runner = const StepBatchRunner(),
  })  : _execution = execution,
        _runner = runner,
        super(const ExecutionState.initial());

  Future<void> advance({
    required StepPace pace,
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    _stopRequested = false;
    if (!_hasStarted) {
      final started = _startNew(
        sourceCode: sourceCode,
        profileId: profileId,
        languageId: languageId,
      );
      if (started.isTerminal) {
        _processStep(started);
        return;
      }
    }
    final from = state.currentStep;
    _settlement = StepSettlement.forPace(pace, from);
    _fromRevision = from.focusRevision;
    await _drain();
  }

  Future<void> provideInput(String rawInput) async {
    if (!_hasStarted) return;
    _processStep(_execution.provideInput(rawInput));
    if (!_hasStarted) return;
    await _drain();
  }

  void stop() {
    _stopRequested = true;
    _execution.stop();
    _hasStarted = false;
    emit(state.copyWith(
      status: ExecutionStatus.idle,
      currentStep: const ExecutionStep(
        stepNumber: 0,
        scopeName: 'global',
        scopeDepth: 1,
      ),
      isOutputStale: state.outputLines.isNotEmpty,
    ));
  }

  void toggleOutputPanel() {
    final newExpanded = !state.isOutputPanelExpanded;
    emit(state.copyWith(
      isOutputPanelExpanded: newExpanded,
      userCollapsedOutput: !newExpanded,
    ));
  }

  void dismissStatusBanner() {
    if (state.isStatusBannerDismissed) return;
    emit(state.copyWith(isStatusBannerDismissed: true));
  }

  Future<void> _drain() async {
    await _runner.runUntilSettled(
      _execution,
      settlement: _settlement,
      fromRevision: _fromRevision,
      shouldStop: () => _stopRequested,
      onStep: _processStep,
    );
    _settle();
  }

  void _settle() {
    if (!_hasStarted || _stopRequested) return;
    if (state.currentStep.isAwaitingInput) return;
    emit(state.copyWith(status: ExecutionStatus.pausedAtStatement));
  }

  ExecutionStep _startNew({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    _hasStarted = true;
    _runCounter++;
    final initialStep = _execution.startExecution(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    emit(ExecutionState(
      status: ExecutionStatus.pausedAtStatement,
      currentStep: initialStep,
      outputLines: _execution.outputLines,
      runId: _runCounter,
      statementNumber: 0,
      isOutputPanelExpanded: state.isOutputPanelExpanded,
      userCollapsedOutput: state.userCollapsedOutput,
    ));
    return initialStep;
  }

  void _processStep(ExecutionStep step) {
    if (step.isTerminal) _hasStarted = false;
    final lines = _execution.outputLines;
    final shouldAutoExpand = lines.isNotEmpty && !state.isOutputPanelExpanded && !state.userCollapsedOutput;

    final advanced = step.focusRevision != state.currentStep.focusRevision;
    emit(state.copyWith(
      status: _statusOf(step),
      currentStep: step,
      outputLines: lines,
      statementNumber: advanced ? state.statementNumber + 1 : state.statementNumber,
      isOutputPanelExpanded: shouldAutoExpand ? true : state.isOutputPanelExpanded,
      haltMessage: step.haltReason,
    ));
  }

  ExecutionStatus _statusOf(ExecutionStep step) {
    if (step.isStepLimitReached) return ExecutionStatus.stepLimitReached;
    if (step.isHalted) return ExecutionStatus.haltedWithError;
    if (step.isFinished) return ExecutionStatus.finishedSuccess;
    if (step.isAwaitingInput) return ExecutionStatus.pausedAwaitingInput;
    return ExecutionStatus.running;
  }
}
