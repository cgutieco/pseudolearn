import 'dart:collection';

import '../../domain/model/execution/effect_settlement.dart';
import '../../domain/model/execution/effect_tape.dart';
import '../../domain/model/execution/execution_projection.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/replay_rejection.dart';
import '../../domain/model/execution/simulated_capabilities.dart';
import '../../domain/model/execution/simulated_scenario.dart';
import '../../domain/model/execution/input_wait.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/execution_reproduction.dart';
import '../../domain/ports/program_execution.dart';
import 'rust_analysis_api.dart';
import 'rust_effect_gate.dart';
import 'rust_execution_api.dart';
import 'rust_execution_event_consumer.dart';
import 'rust_execution_opening.dart';
import 'rust_execution_reproduction.dart';
import 'rust_execution_resource.dart';
import 'rust_execution_step_builder.dart';
import 'rust_focus_tracker.dart';
import 'rust_replay_host.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustProgramExecution
    implements ProgramExecution, ExecutionReproduction {
  static const int batchSize = 25;
  final RustAnalysisApi _analysis;
  final RustExecutionApi _execution;
  final RustExecutionEventConsumer _events;
  final _reproduction = RustExecutionReproduction();
  late final RustEffectGate _gate;
  final SimulatedCapabilities _defaultCapabilities;
  static const _stepBuilder = RustExecutionStepBuilder();
  final _queue = Queue<RustEvent>();

  RustOpenedProgram? _opened;
  int? _executionId;
  RustFocusTracker? _tracker;
  RustBatch? _last;
  RustTerminationKind _termination = RustTerminationKind.running;
  String? _failureReason;
  int _eventIndex = -1;
  int _stepCounter = 0;

  RustProgramExecution(
    RustTransport transport, {
    SimulatedCapabilities capabilities = SimulatedCapabilities.none,
    bool autoResolveEffects = true,
    RustExecutionResource? observationResource,
  }) : _analysis = RustAnalysisApi(transport),
       _execution = RustExecutionApi(transport, resource: observationResource),
       _events = RustExecutionEventConsumer(transport),
       _gate = RustEffectGate(transport, capabilities, autoResolveEffects),
       _defaultCapabilities = capabilities;

  @override
  List<OutputLine> get outputLines => _events.outputLines;

  @override
  EffectTape? get recordedTape => _reproduction.recordedTape;

  @override
  ReplayRejection? get replayRejection => _reproduction.rejection;

  @override
  ExecutionProjection get projection => _reproduction.projection(
    termination: _termination,
    output: _events.outputLines,
    failure: _failureReason,
  );

  @override
  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    SimulatedScenario? scenario,
    EffectTape? replayTape,
  }) {
    stop();
    _reproduction.begin(replaying: replayTape != null);
    final capabilities = scenario?.capabilities ?? _defaultCapabilities;
    _gate.reset(replayTape == null ? capabilities : SimulatedCapabilities.none);
    final opened = RustExecutionOpening(_analysis).open(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    if (opened == null) return const ExecutionStep.unstarted();
    _opened = opened;
    _tracker = RustFocusTracker(opened.view);
    try {
      _executionId = _execution.start(
        opened.handle,
        replayTape == null
            ? _gate.hostDocument
            : replayHostDocument(capabilities),
        opened.view.revision,
        replay: replayTape,
      );
    } on RustBridgeFailure catch (failure) {
      if (replayTape == null) rethrow;
      _reproduction.reject(failure);
      stop();
      return const ExecutionStep.unstarted();
    }
    return _snapshot();
  }

  @override
  ExecutionStep step() {
    if (_executionId == null) return const ExecutionStep.exhausted();
    _stepCounter++;
    if (_queue.isEmpty && _termination == RustTerminationKind.running) {
      try {
        _fetchBatch();
      } on FormatException {
        _fail('invalid_event_batch');
      } on TypeError {
        _fail('invalid_event_batch');
      } on RustBridgeFailure catch (failure) {
        if (!_reproduction.replaying) rethrow;
        _fail(_reproduction.reject(failure).code);
      }
    }
    if (_queue.isNotEmpty) return _consume(_queue.removeFirst());
    return _terminalStep();
  }

  ExecutionStep _terminalStep() {
    _tracker!.finishRoot(_termination, _failureReason);
    return _stepBuilder.terminal(
      tracker: _tracker!,
      stepNumber: _stepCounter,
      eventIndex: _eventIndex,
      termination: _termination,
      batch: _last,
      inputPrompt: _events.inputPrompt,
      failureReason: _failureReason,
    );
  }

  @override
  ExecutionStep provideInput(InputWait request, String rawInput) {
    final execution = _executionId;
    if (execution == null) return const ExecutionStep.exhausted();
    final pending = _last?.pendingInput?.toDomain();
    if (request.resourceId != execution || pending?.matches(request) != true) {
      return _terminalStep();
    }
    _execution.provideInput(execution, request, rawInput);
    _termination = RustTerminationKind.running;
    _failureReason = null;
    _events.clearInputPrompt();
    return step();
  }

  @override
  void stop() {
    final handle = _opened?.handle;
    final execution = _executionId;
    _opened = null;
    _executionId = null;
    _queue.clear();
    _termination = RustTerminationKind.running;
    _eventIndex = -1;
    _stepCounter = 0;
    _tracker = null;
    _last = null;
    _failureReason = null;
    _events.clear();
    _gate.close();
    _execution.stop(execution);
    if (handle != null) _analysis.release(handle);
  }

  @override
  ExecutionStep settleEffect(EffectSettlement settlement) {
    if (settlement == EffectSettlement.cancel) {
      final number = _stepCounter;
      stop();
      return _stepBuilder.cancelled(number);
    }
    final batch = _last;
    final execution = _executionId;
    if (execution == null ||
        batch?.pendingEffect == null ||
        !_gate.canResolve) {
      return step();
    }
    _gate.answer(execution, batch!);
    _termination = RustTerminationKind.running;
    return step();
  }

  void _fetchBatch() {
    final collected = <RustEvent>[];
    final batch = _gate.drain(_executionId!, batchSize, collected);
    _queue.addAll(collected);
    _last = batch;
    _reproduction.observed(batch);
    _termination = batch.termination;
    if (batch.termination
        case RustTerminationKind.completed ||
            RustTerminationKind.cancelled ||
            RustTerminationKind.failed ||
            RustTerminationKind.limitReached) {
      _gate.close();
    }
  }

  void _fail(String reason) {
    _termination = RustTerminationKind.failed;
    _failureReason = reason;
  }

  ExecutionStep _consume(RustEvent event) {
    _eventIndex++;
    _reproduction.consumed(event);
    final failure = _events.consume(
      event: event,
      eventIndex: _eventIndex,
      execution: _executionId!,
      view: _opened!.view,
      offsets: _opened!.offsets,
      tracker: _tracker!,
    );
    if (failure != null) {
      _fail(failure);
      _queue.clear();
      return _snapshot(halted: true, reason: _failureReason);
    }
    return _snapshot();
  }

  ExecutionStep _snapshot({bool halted = false, String? reason}) =>
      _stepBuilder.build(
        tracker: _tracker!,
        stepNumber: _stepCounter,
        eventIndex: _eventIndex,
        halted: halted,
        reason: reason,
      );
}
