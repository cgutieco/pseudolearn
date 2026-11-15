import '../../domain/model/execution/effect_wait.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/input_wait.dart';
import 'rust_effect_gate.dart';
import 'rust_focus_tracker.dart';
import 'rust_wire_models.dart';

final class RustExecutionStepBuilder {
  const RustExecutionStepBuilder();

  ExecutionStep build({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    EffectWait? pending,
    bool finished = false,
    bool halted = false,
    bool cancelled = false,
    bool awaitingInput = false,
    InputWait? inputWait,
    String? prompt,
    String? reason,
  }) => _executionStep(
    tracker: tracker,
    stepNumber: stepNumber,
    eventIndex: eventIndex,
    pending: pending,
    finished: finished,
    halted: halted,
    cancelled: cancelled,
    awaitingInput: awaitingInput,
    inputWait: inputWait,
    prompt: prompt,
    reason: reason,
  );

  ExecutionStep _executionStep({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    EffectWait? pending,
    bool finished = false,
    bool halted = false,
    bool cancelled = false,
    bool awaitingInput = false,
    InputWait? inputWait,
    String? prompt,
    String? reason,
  }) => ExecutionStep(
    stepNumber: stepNumber,
    eventIndex: eventIndex,
    taskId: tracker.currentTaskId,
    taskContexts: tracker.taskContexts,
    focus: tracker.focus,
    focusRevision: tracker.focusRevision,
    blockPosition: tracker.blockPosition,
    scopeName: tracker.scopeName,
    scopeDepth: tracker.scopeDepth,
    variables: tracker.variables,
    isFinished: finished,
    isHalted: halted,
    isCancelled: cancelled,
    haltReason: reason,
    isAwaitingInput: awaitingInput,
    inputWait: inputWait,
    inputPrompt: prompt,
    pendingEffect: pending,
  );

  ExecutionStep terminal({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    required RustTerminationKind termination,
    required RustBatch? batch,
    required String? inputPrompt,
    required String? failureReason,
  }) => switch (termination) {
    RustTerminationKind.completed => _finished(tracker, stepNumber, eventIndex),
    RustTerminationKind.cancelled => _cancelled(tracker, stepNumber, eventIndex),
    RustTerminationKind.awaitingInput => _awaitingInput(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
      batch: batch,
      prompt: inputPrompt,
    ),
    RustTerminationKind.awaitingEffect => _awaitingEffect(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
      batch: batch,
    ),
    RustTerminationKind.limitReached => _limitReached(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
    ),
    _ => _halted(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
      failureReason: failureReason,
      batch: batch,
    ),
  };

  ExecutionStep _cancelled(
    RustFocusTracker tracker,
    int stepNumber,
    int eventIndex,
  ) => build(
    tracker: tracker,
    stepNumber: stepNumber,
    eventIndex: eventIndex,
    cancelled: true,
    reason: 'cancelled_by_host',
  );

  ExecutionStep _awaitingInput({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    required RustBatch? batch,
    required String? prompt,
  }) => build(
    tracker: tracker,
    stepNumber: stepNumber,
    eventIndex: eventIndex,
    awaitingInput: true,
    inputWait: batch?.pendingInput?.toDomain(),
    prompt: prompt,
  );

  ExecutionStep _limitReached({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
  }) => build(
    tracker: tracker,
    stepNumber: stepNumber,
    eventIndex: eventIndex,
  ).asStepLimitReached();

  ExecutionStep _halted({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    required String? failureReason,
    required RustBatch? batch,
  }) => build(
    tracker: tracker,
    stepNumber: stepNumber,
    eventIndex: eventIndex,
    halted: true,
    reason: failureReason ?? batch?.failureMessage ?? batch?.failureCode,
  );

  ExecutionStep _finished(
    RustFocusTracker tracker,
    int stepNumber,
    int eventIndex,
  ) => build(
    tracker: tracker,
    stepNumber: stepNumber,
    eventIndex: eventIndex,
    finished: true,
  );

  ExecutionStep _awaitingEffect({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    required RustBatch? batch,
  }) => build(
    tracker: tracker,
    stepNumber: stepNumber,
    eventIndex: eventIndex,
    pending: RustEffectGate.waitOf(batch?.pendingEffect),
  );
}
