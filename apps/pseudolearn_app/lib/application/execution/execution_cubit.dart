import 'package:bloc/bloc.dart';
import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/input_wait.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/model/execution/simulated_scenario.dart';
import '../../domain/ports/program_execution.dart';
import 'execution_state.dart';
import 'execution_status_from_step.dart';
import 'step_batch_runner.dart';
import 'step_pace.dart';
import 'step_settlement.dart';

final class ExecutionCubit extends Cubit<ExecutionState> {
  final ProgramExecution _execution;
  final StepBatchRunner _runner;
  Future<void> _commandTail = Future<void>.value();
  bool _stopRequested = false;
  bool _hasStarted = false;
  int _commandEpoch = 0;
  int _runCounter = 0;
  StepSettlement _settlement = const StepSettlement.atAnyFocusChange();
  int _fromRevision = 0;

  ExecutionCubit({
    required ProgramExecution execution,
    StepBatchRunner runner = const StepBatchRunner(),
  }) : _execution = execution,
       _runner = runner,
       super(const ExecutionState.initial());

  Future<void> advance({
    required StepPace pace,
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) => _enqueue(
    () => _advance(
      pace: pace,
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    ),
  );

  Future<void> advanceTask({required int taskId}) => _enqueue(() async {
    if (!_hasStarted || state.status != ExecutionStatus.pausedAtStatement) {
      return;
    }
    if (!_canAdvanceTask(taskId)) return;
    _stopRequested = false;
    final from = state.currentStep;
    _settlement = StepSettlement.forTask(taskId: taskId, from: from);
    _fromRevision = from.focusRevision;
    await _drain();
  });

  Future<void> _advance({
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

  Future<void> provideInput(InputWait request, String rawInput) =>
      _enqueue(() async {
        if (!_hasStarted) return;
        final pending = state.currentStep.inputWait;
        if (pending == null || !pending.matches(request)) return;
        final step = _execution.provideInput(request, rawInput);
        _processStep(step);
        if (!_hasStarted) return;
        if (_settlement.settlesOn(step, _fromRevision)) {
          _settle();
          return;
        }
        await _drain();
      });

  void stop() {
    _commandEpoch++;
    _stopRequested = true;
    _execution.stop();
    _hasStarted = false;
    emit(
      state.copyWith(
        status: ExecutionStatus.idle,
        currentStep: const ExecutionStep(
          stepNumber: 0,
          scopeName: 'global',
          scopeDepth: 1,
        ),
        isOutputStale: state.outputLines.isNotEmpty,
      ),
    );
  }

  void applyViewAction(
    ExecutionViewAction action, {
    SimulatedScenario? scenario,
  }) => emit(state.applyViewAction(action, scenario: scenario));

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
    if (state.currentStep.isAwaitingInput ||
        state.currentStep.isAwaitingEffect) {
      return;
    }
    emit(state.copyWith(status: ExecutionStatus.pausedAtStatement));
  }

  Future<void> _enqueue(Future<void> Function() command) {
    final epoch = _commandEpoch;
    final pending = _commandTail.then((_) async {
      if (epoch != _commandEpoch || isClosed) return;
      await command();
    });
    _commandTail = pending.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return pending;
  }

  bool _canAdvanceTask(int taskId) {
    for (final task in state.currentStep.taskContexts) {
      if (task.taskId != taskId) continue;
      return task.status != ExecutionTaskStatus.completed;
    }
    return false;
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
      scenario: state.simulatedScenario,
    );
    emit(
      ExecutionState(
        status: ExecutionStatus.pausedAtStatement,
        currentStep: initialStep,
        outputLines: _execution.outputLines,
        runId: _runCounter,
        statementNumber: 0,
        isOutputPanelExpanded: state.isOutputPanelExpanded,
        userCollapsedOutput: state.userCollapsedOutput,
        simulatedScenario: state.simulatedScenario,
      ),
    );
    return initialStep;
  }

  void _processStep(ExecutionStep step) {
    if (step.isTerminal) _hasStarted = false;
    final lines = _execution.outputLines;
    final shouldAutoExpand =
        lines.isNotEmpty &&
        !state.isOutputPanelExpanded &&
        !state.userCollapsedOutput;

    final advanced = step.focusRevision != state.currentStep.focusRevision;
    emit(
      state.copyWith(
        status: executionStatusFromStep(step),
        currentStep: step,
        outputLines: lines,
        statementNumber: advanced
            ? state.statementNumber + 1
            : state.statementNumber,
        isOutputPanelExpanded: shouldAutoExpand
            ? true
            : state.isOutputPanelExpanded,
        haltMessage: step.haltReason,
      ),
    );
  }
}
