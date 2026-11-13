import '../../domain/model/execution/replay_rejection.dart';
import '../../domain/model/execution/effect_tape.dart';
import 'package:bloc/bloc.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/input_wait.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/model/execution/execution_configuration.dart';
import '../../domain/ports/program_execution.dart';
import '../../domain/ports/variable_observation.dart';
import 'execution_state.dart';
import 'execution_state_publisher.dart';
import 'execution_step_projection.dart';
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
  StepPace _pace = StepPace.nextStatement;
  late final ExecutionStatePublisher _publisher = ExecutionStatePublisher(emit);

  ExecutionCubit({
    required this._execution,
    this._runner = const StepBatchRunner(),
  }) : super(const ExecutionState.initial());

  Future<void> advance({
    required StepPace pace,
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    ExecutionConfiguration configuration = const ExecutionConfiguration(),
    bool replay = false,
  }) => _enqueue(
    () => _advance(
      pace: pace,
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      configuration: configuration,
      replay: replay,
    ),
  );

  Future<void> advanceTask({required int taskId}) => _enqueue(() async {
    if (!_hasStarted || state.status != ExecutionStatus.pausedAtStatement) {
      return;
    }
    if (!state.canAdvanceTask(taskId)) return;
    _stopRequested = false;
    _adoptPace(StepPace.nextEvent);
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
    ExecutionConfiguration configuration = const ExecutionConfiguration(),
    bool replay = false,
  }) async {
    _stopRequested = false;
    _adoptPace(pace);
    final tape = replay ? state.recordedTape : null;
    if (replay && tape == null) {
      emit(state.copyWith(replayRejection: ReplayRejection.missingTape));
      return;
    }
    if (replay) {
      _execution.stop();
      _hasStarted = false;
    }
    if (!_hasStarted) {
      final started = _startNew(
        sourceCode: sourceCode,
        profileId: profileId,
        languageId: languageId,
        configuration: configuration,
        replayTape: tape,
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
    final current = _publisher.latest(state);
    _publisher.discard();
    emit(
      current.copyWith(
        status: ExecutionStatus.idle,
        currentStep: const ExecutionState.initial().currentStep,
        isOutputStale: current.outputLines.isNotEmpty,
      ),
    );
  }

  void applyViewAction(ExecutionViewAction action) {
    final current = _publisher.latest(state);
    _publisher.discard();
    emit(current.applyViewAction(action));
    _adoptPace(_pace);
  }

  void _adoptPace(StepPace pace) {
    _pace = pace;
    final continuous = pace == StepPace.toEnd;
    final observes = state.isTraceVisible || !continuous;
    if (_execution case final VariableObservation observation) {
      observation.observesVariables = observes;
    }
    if (observes == state.observesVariables &&
        continuous == state.isContinuous) {
      return;
    }
    emit(
      state.withVisibility(
        observesVariables: observes,
        isContinuous: continuous,
      ),
    );
  }

  Future<void> _drain() async {
    await _runner.runUntilSettled(
      _execution,
      settlement: _settlement,
      fromRevision: _fromRevision,
      shouldStop: () => _stopRequested,
      onStep: _processStep,
    );
    _publisher.flush();
    _settle();
  }

  void _settle() {
    if (!_hasStarted || _stopRequested) return;
    final step = state.currentStep;
    if (step.isAwaitingInput || step.isAwaitingEffect) return;
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

  ExecutionStep _startNew({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    ExecutionConfiguration configuration = const ExecutionConfiguration(),
    EffectTape? replayTape,
  }) {
    _hasStarted = true;
    _runCounter++;
    final initialStep = _execution.startExecution(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      configuration: configuration,
      replayTape: replayTape,
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
        isTraceVisible: state.isTraceVisible,
        isTasksVisible: state.isTasksVisible,
        observesVariables: state.observesVariables,
        isContinuous: state.isContinuous,
        configuration: configuration,
        recordedTape: replayTape,
      ),
    );
    return initialStep;
  }

  void _processStep(ExecutionStep step) {
    if (step.isTerminal) _hasStarted = false;
    final current = _publisher.latest(state);
    _publisher.publish(
      stateAfterStep(current, step, _execution),
      throttled: current.isContinuous && !current.observesVariables,
    );
  }
}
