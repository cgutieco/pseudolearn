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
import 'rust_execution_readers.dart';
import 'rust_focus_tracker.dart';
import 'rust_output_assembler.dart';
import 'rust_profile_name.dart';
import 'rust_program_view.dart';
import 'rust_state_api.dart';
import 'rust_transport.dart';
import 'rust_watch_rows.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

final class RustProgramExecution implements ProgramExecution {
  static const int batchSize = 25;
  static const Set<String> _environmentEvents = {
    'statement_entered',
    'statement_exited',
    'decision',
    'call',
    'return',
  };

  final RustAnalysisApi _analysis;
  final RustExecutionApi _execution;
  final RustWatchRows _watch;
  final RustEffectGate _gate;
  final Queue<RustEvent> _queue = Queue<RustEvent>();

  RustAnalysisHandle? _handle;
  int? _executionId;
  RustProgramView? _view;
  RustFocusTracker? _tracker;
  SourceOffsetIndex? _offsets;
  RustOutputAssembler _output = RustOutputAssembler();
  RustEnvironment _environment = const RustEnvironment(
    rows: [],
    scopeName: 'global',
    depth: 1,
  );
  RustBatch? _last;
  RustTerminationKind _termination = RustTerminationKind.running;
  String? _inputPrompt;
  int _eventIndex = -1;
  int _stepCounter = 0;

  RustProgramExecution(
    RustTransport transport, {
    SimulatedCapabilities capabilities = SimulatedCapabilities.none,
    bool autoResolveEffects = true,
  }) : _analysis = RustAnalysisApi(transport),
       _execution = RustExecutionApi(transport),
       _watch = RustWatchRows(RustStateApi(transport)),
       _gate = RustEffectGate(transport, capabilities, autoResolveEffects);

  @override
  List<OutputLine> get outputLines => List.unmodifiable(_output.lines);

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
    final view = RustProgramView.fromJson(
      _analysis.programView(handle),
      offsets,
    );
    _handle = handle;
    _offsets = offsets;
    _view = view;
    _tracker = RustFocusTracker(view);
    _executionId = _execution.start(handle, host: _gate.hostDocument);
    return _snapshot();
  }

  @override
  ExecutionStep step() {
    if (_executionId == null) return const ExecutionStep.exhausted();
    _stepCounter++;
    if (_queue.isEmpty && _termination == RustTerminationKind.running) {
      _fetchBatch();
    }
    if (_queue.isNotEmpty) return _consume(_queue.removeFirst());
    return _terminalStep();
  }

  @override
  ExecutionStep provideInput(String rawInput) {
    final execution = _executionId;
    if (execution == null) return step();
    _execution.provideInput(execution, rawInput);
    _termination = RustTerminationKind.running;
    _inputPrompt = null;
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
    _output = RustOutputAssembler();
    _environment = const RustEnvironment(
      rows: [],
      scopeName: 'global',
      depth: 1,
    );
    if (execution != null) _execution.cancel(execution);
    if (handle != null) _analysis.release(handle);
  }

  @override
  ExecutionStep settleEffect(EffectSettlement settlement) {
    if (settlement == EffectSettlement.cancel) return _cancelled();
    final batch = _last;
    final execution = _executionId;
    if (execution == null || batch?.pendingEffect == null || !_gate.canResolve) {
      return step();
    }
    _gate.answer(execution, batch!);
    _termination = RustTerminationKind.running;
    return step();
  }

  ExecutionStep _cancelled() {
    final number = _stepCounter;
    stop();
    return ExecutionStep(
      stepNumber: number,
      scopeName: 'global',
      scopeDepth: 1,
      isHalted: true,
      haltReason: 'cancelled',
    );
  }

  void _fetchBatch() {
    final collected = <RustEvent>[];
    final batch = _gate.drain(_executionId!, batchSize, collected);
    _queue.addAll(collected);
    _last = batch;
    _termination = batch.termination;
  }

  ExecutionStep _consume(RustEvent event) {
    _eventIndex++;
    _tracker!.apply(event);
    _recordEffects(event);
    if (_environmentEvents.contains(event.eventClass)) {
      _environment = _watch.at(
        execution: _executionId!,
        event: _eventIndex,
        depth: event.depth,
      );
    }
    return _snapshot();
  }

  void _recordEffects(RustEvent event) {
    switch (event.eventClass) {
      case 'output':
        _output.append('${event.data['texto']}');
      case 'input_received':
        _output.echoInput('${event.data['texto']}');
      case 'input_requested':
        _inputPrompt = inputPromptOf(_view!, _offsets!, event);
    }
  }

  ExecutionStep _terminalStep() {
    final batch = _last;
    return switch (_termination) {
      RustTerminationKind.completed => _snapshot(finished: true),
      RustTerminationKind.awaitingInput => _snapshot(
        awaitingInput: true,
        prompt: _inputPrompt,
      ),
      RustTerminationKind.awaitingEffect => _snapshot(
        pending: RustEffectGate.waitOf(batch?.pendingEffect),
      ),
      RustTerminationKind.limitReached => _snapshot().asStepLimitReached(),
      _ => _snapshot(
        halted: true,
        reason: batch?.failureMessage ?? batch?.failureCode,
      ),
    };
  }

  ExecutionStep _snapshot({
    EffectWait? pending,
    bool finished = false,
    bool halted = false,
    bool awaitingInput = false,
    String? prompt,
    String? reason,
  }) {
    final tracker = _tracker!;
    return ExecutionStep(
      stepNumber: _stepCounter,
      focus: tracker.focus,
      focusRevision: tracker.focusRevision,
      blockPosition: tracker.blockPosition,
      scopeName: _environment.scopeName,
      scopeDepth: _environment.depth,
      variables: List.unmodifiable(_environment.rows),
      isFinished: finished,
      isHalted: halted,
      haltReason: reason,
      isAwaitingInput: awaitingInput,
      inputPrompt: prompt,
      pendingEffect: pending,
    );
  }
}
