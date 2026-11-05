import 'dart:collection';

import '../../domain/model/execution/execution_step.dart';
import 'rust_effect_gate.dart';
import 'rust_execution_event_consumer.dart';
import 'rust_execution_reproduction.dart';
import 'rust_execution_step_builder.dart';
import 'rust_focus_tracker.dart';
import 'rust_program_view.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

final class RustExecutionEventProgress {
  final RustExecutionEventConsumer _consumer;
  final RustExecutionReproduction _reproduction;
  final RustExecutionStepBuilder _stepBuilder;
  final Queue<RustEvent> events = Queue<RustEvent>();

  RustBatch? last;
  RustTerminationKind termination = RustTerminationKind.running;
  int eventIndex = -1;

  RustExecutionEventProgress({
    required RustExecutionEventConsumer consumer,
    required RustExecutionReproduction reproduction,
    required RustExecutionStepBuilder stepBuilder,
  }) : _consumer = consumer,
       _reproduction = reproduction,
       _stepBuilder = stepBuilder;

  RustBatch drain(RustEffectGate gate, int execution, int batchSize) {
    final collected = <RustEvent>[];
    final batch = gate.drain(execution, batchSize, collected);
    events.addAll(collected);
    observeBatch(batch);
    if (batch.termination
        case RustTerminationKind.completed ||
            RustTerminationKind.cancelled ||
            RustTerminationKind.failed ||
            RustTerminationKind.limitReached) {
      gate.close();
    }
    return batch;
  }

  void observeBatch(RustBatch batch) {
    last = batch;
    _reproduction.observed(batch);
    termination = batch.termination;
  }

  ExecutionStep consume({
    required RustEvent event,
    required int execution,
    required RustProgramView view,
    required SourceOffsetIndex offsets,
    required RustFocusTracker tracker,
    required int stepNumber,
    required void Function(String) onFailure,
  }) {
    eventIndex++;
    _reproduction.consumed(event);
    final failure = _consumer.consume(
      event: event,
      eventIndex: eventIndex,
      execution: execution,
      view: view,
      offsets: offsets,
      tracker: tracker,
      errorRanges: last?.errorRanges ?? const [],
    );
    if (failure != null) {
      onFailure(failure);
      events.clear();
      return _stepBuilder.build(
        tracker: tracker,
        stepNumber: stepNumber,
        eventIndex: eventIndex,
        halted: true,
        reason: failure,
      );
    }
    return _stepBuilder.build(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
    );
  }

  void clear() {
    events.clear();
    last = null;
    termination = RustTerminationKind.running;
    eventIndex = -1;
  }
}
