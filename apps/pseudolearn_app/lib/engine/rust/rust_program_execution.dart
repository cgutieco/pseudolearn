import 'dart:collection';

import '../../domain/model/execution/effect_settlement.dart';
import '../../domain/model/execution/effect_wait.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/simulated_capabilities.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_execution.dart';
import 'rust_analysis_api.dart';
import 'rust_effect_gate.dart';
import 'rust_execution_api.dart';
import 'rust_execution_event_effects.dart';
import 'rust_execution_resource.dart';
import 'rust_execution_readers.dart';
import 'rust_execution_step_builder.dart';
import 'rust_focus_tracker.dart';
import 'rust_profile_name.dart';
import 'rust_program_view.dart';
import 'rust_program_view_read_result.dart';
import 'rust_state_api.dart';
import 'rust_transport.dart';
import 'rust_watch_rows.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

final class RustProgramExecution implements ProgramExecution {
  static const int batchSize = 25;

  final RustAnalysisApi _analysis;
  final RustExecutionApi _execution;
  final RustWatchRows _watch;
  final RustEffectGate _gate;
  final RustExecutionEventEffects _eventEffects = RustExecutionEventEffects();
  static const RustExecutionStepBuilder _stepBuilder =
      RustExecutionStepBuilder();
  final Queue<RustEvent> _queue = Queue<RustEvent>();

  RustAnalysisHandle? _handle;
  int? _executionId;
  RustProgramView? _view;
  RustFocusTracker? _tracker;
  SourceOffsetIndex? _offsets;
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
       _watch = RustWatchRows(RustStateApi(transport)),
       _gate = RustEffectGate(transport, capabilities, autoResolveEffects);

  @override
  List<OutputLine> get outputLines => _eventEffects.outputLines;

  @override
  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    stop();
    final handle = _analysis.open(
      source: sourceCode,
      profile: rustProfileName(profileId),
      locale: rustLocaleName(languageId),
    );
    final report = _analysis.report(handle);
    if (!isExecutableReport(report)) {
      _analysis.release(handle);
      return const ExecutionStep.unstarted();
    }
    final offsets = SourceOffsetIndex(sourceCode);
    final viewResult = RustProgramView.decode(
      _analysis.programView(handle),
      offsets,
    );
    if (viewResult is! RustProgramViewReadSuccess) {
      _analysis.release(handle);
      return const ExecutionStep.unstarted();
    }
    final view = viewResult.view;
    _handle = handle;
    _offsets = offsets;
    _view = view;
    _tracker = RustFocusTracker(view);
    _executionId = _execution.start(handle, _gate.hostDocument, view.revision);
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
        _failInvalidBatch();
      } on TypeError {
        _failInvalidBatch();
      }
    }
    if (_queue.isNotEmpty) return _consume(_queue.removeFirst());
    _tracker!.finishRoot(_termination, _failureReason);
    return _stepBuilder.terminal(
      tracker: _tracker!,
      stepNumber: _stepCounter,
      eventIndex: _eventIndex,
      termination: _termination,
      batch: _last,
      inputPrompt: _eventEffects.inputPrompt,
      failureReason: _failureReason,
    );
  }

  @override
  ExecutionStep provideInput(String rawInput) {
    final execution = _executionId;
    if (execution == null) return step();
    _execution.provideInput(execution, rawInput);
    _termination = RustTerminationKind.running;
    _failureReason = null;
    _eventEffects.clearInputPrompt();
    return step();
  }

  @override
  void stop() {
    final handle = _handle;
    final execution = _executionId;
    _handle = null;
    _executionId = null;
    _queue.clear();
    _termination = RustTerminationKind.running;
    _eventIndex = -1;
    _stepCounter = 0;
    _tracker = null;
    _view = null;
    _offsets = null;
    _last = null;
    _failureReason = null;
    _eventEffects.clear();
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
    _termination = batch.termination;
  }

  void _failInvalidBatch() {
    _termination = RustTerminationKind.failed;
    _failureReason = 'invalid_event_batch';
  }

  ExecutionStep _consume(RustEvent event) {
    _eventIndex++;
    try {
      if (!_tracker!.apply(event, _eventIndex)) {
        _termination = RustTerminationKind.failed;
        _failureReason = 'invalid_event_sequence';
        _queue.clear();
        return _snapshot(halted: true, reason: _failureReason);
      }
    } on Object {
      _termination = RustTerminationKind.failed;
      _failureReason = 'invalid_event';
      _queue.clear();
      return _snapshot(halted: true, reason: _failureReason);
    }
    _eventEffects.record(event, _view!, _offsets!);
    if (rustEventRequiresEnvironment(event.eventClass)) {
      final result = _watch.at(
        execution: _executionId!,
        event: _eventIndex,
        taskId: _tracker!.currentTaskId,
        depth: event.depth,
      );
      if (result is RustEnvironmentFailure) {
        _termination = RustTerminationKind.failed;
        _failureReason = result.reason;
        _queue.clear();
        return _snapshot(halted: true, reason: _failureReason);
      }
      final environment = (result as RustEnvironmentValue).environment;
      _tracker!.recordEnvironment(
        taskId: _tracker!.currentTaskId,
        eventIndex: _eventIndex,
        scopeName: environment.scopeName,
        scopeDepth: environment.depth,
        variables: environment.rows,
      );
    }
    return _snapshot();
  }

  ExecutionStep _snapshot({
    EffectWait? pending,
    bool finished = false,
    bool halted = false,
    bool awaitingInput = false,
    String? prompt,
    String? reason,
  }) {
    return _stepBuilder.build(
      tracker: _tracker!,
      stepNumber: _stepCounter,
      eventIndex: _eventIndex,
      pending: pending,
      finished: finished,
      halted: halted,
      awaitingInput: awaitingInput,
      prompt: prompt,
      reason: reason,
    );
  }
}
