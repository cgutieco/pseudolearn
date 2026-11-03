import '../../domain/ports/execution_context.dart';
import '../../domain/model/execution/effect_settlement.dart';
import '../../domain/model/execution/effect_tape.dart';
import '../../domain/model/execution/execution_projection.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/replay_rejection.dart';
import '../../domain/model/execution/execution_configuration.dart';
import '../../domain/ports/execution_environment.dart';
import '../../domain/model/execution/input_wait.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/execution_reproduction.dart';
import '../../domain/ports/program_execution.dart';
import 'rust_analysis_api.dart';
import 'rust_effect_gate.dart';
import 'rust_execution_api.dart';
import 'rust_execution_event_consumer.dart';
import 'rust_execution_effect_settlement.dart';
import 'rust_execution_event_progress.dart';
import 'rust_execution_opening.dart';
import 'rust_execution_reproduction.dart';
import 'rust_execution_resource.dart';
import 'rust_execution_step_builder.dart';
import 'rust_focus_tracker.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

part 'rust_program_execution_start.dart';

final class RustProgramExecution
    implements ProgramExecution, ExecutionReproduction, ExecutionContext {
  static const int batchSize = 25;
  final RustAnalysisApi _analysis;
  final RustExecutionApi _execution;
  final RustExecutionEventConsumer _events;
  final _reproduction = RustExecutionReproduction();
  late final RustEffectGate _gate;
  static const _stepBuilder = RustExecutionStepBuilder();
  static const _effectSettlement = RustExecutionEffectSettlement();
  late final _progress = RustExecutionEventProgress(
    consumer: _events,
    reproduction: _reproduction,
    stepBuilder: _stepBuilder,
  );

  RustOpenedProgram? _opened;
  int? _executionId;
  RustFocusTracker? _tracker;
  String? _failureReason;
  int _stepCounter = 0;

  RustProgramExecution(
    RustTransport transport, {
    ExecutionEnvironment? environment,
    bool autoResolveEffects = true,
    RustExecutionResource? observationResource,
  }) : _analysis = RustAnalysisApi(transport),
       _execution = RustExecutionApi(transport, resource: observationResource),
       _events = RustExecutionEventConsumer(transport),
       _gate = RustEffectGate(transport, environment, autoResolveEffects);

  @override
  List<OutputLine> get outputLines => _events.outputLines;

  @override
  String? get workingDirectory => _gate.workingDirectory;

  @override
  EffectTape? get recordedTape => _reproduction.recordedTape;

  @override
  ReplayRejection? get replayRejection => _reproduction.rejection;

  @override
  ExecutionProjection get projection => _reproduction.projection(
    termination: _progress.termination,
    output: _events.outputLines,
    failure: _failureReason,
  );

  @override
  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    ExecutionConfiguration configuration = const ExecutionConfiguration(),
    EffectTape? replayTape,
  }) {
    return _startConfigured(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
      configuration: configuration,
      replayTape: replayTape,
    );
  }

  @override
  ExecutionStep step() {
    if (_executionId == null) return const ExecutionStep.exhausted();
    _stepCounter++;
    if (_progress.events.isEmpty &&
        _progress.termination == RustTerminationKind.running) {
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
    if (_progress.events.isNotEmpty) {
      return _consume(_progress.events.removeFirst());
    }
    return _terminalStep();
  }

  ExecutionStep _terminalStep() {
    _tracker!.finishRoot(_progress.termination, _failureReason);
    return _stepBuilder.terminal(
      tracker: _tracker!,
      stepNumber: _stepCounter,
      eventIndex: _progress.eventIndex,
      termination: _progress.termination,
      batch: _progress.last,
      inputPrompt: _events.inputPrompt,
      failureReason: _failureReason,
    );
  }

  @override
  ExecutionStep provideInput(InputWait request, String rawInput) {
    final execution = _executionId;
    if (execution == null) return const ExecutionStep.exhausted();
    final pending = _progress.last?.pendingInput?.toDomain();
    if (request.resourceId != execution || pending?.matches(request) != true) {
      return _terminalStep();
    }
    _execution.provideInput(execution, request, rawInput);
    _progress.termination = RustTerminationKind.running;
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
    _progress.clear();
    _stepCounter = 0;
    _tracker = null;
    _failureReason = null;
    _events.clear();
    _gate.close();
    _execution.stop(execution);
    if (handle != null) _analysis.release(handle);
  }

  @override
  ExecutionStep settleEffect(EffectSettlement settlement) =>
      _effectSettlement.settle(
        settlement: settlement,
        batch: _progress.last,
        execution: _executionId,
        gate: _gate,
        advance: step,
        onResolved: () {
          _progress.termination = RustTerminationKind.running;
        },
        cancel: _cancelEffect,
      );

  ExecutionStep _cancelEffect() => _effectSettlement.cancel(
    executionApi: _execution,
    execution: _executionId,
    batchSize: batchSize,
    observe: _progress.observeBatch,
    consume: _consume,
    snapshot: _snapshot,
    terminal: _terminalStep,
    releaseConfirmed: _releaseConfirmed,
  );

  void _releaseConfirmed() {
    final handle = _opened?.handle;
    final execution = _executionId;
    _opened = null;
    _executionId = null;
    _progress.events.clear();
    _progress.last = null;
    _tracker = null;
    _gate.close();
    _execution.stop(execution, cancel: false);
    if (handle != null) _analysis.release(handle);
  }

  void _fetchBatch() => _progress.drain(_gate, _executionId!, batchSize);

  void _fail(String reason) {
    _progress.termination = RustTerminationKind.failed;
    _failureReason = reason;
  }

  ExecutionStep _consume(RustEvent event) => _progress.consume(
    event: event,
    execution: _executionId!,
    view: _opened!.view,
    offsets: _opened!.offsets,
    tracker: _tracker!,
    stepNumber: _stepCounter,
    onFailure: _fail,
  );

  ExecutionStep _snapshot() => _stepBuilder.build(
    tracker: _tracker!,
    stepNumber: _stepCounter,
    eventIndex: _progress.eventIndex,
  );
}
