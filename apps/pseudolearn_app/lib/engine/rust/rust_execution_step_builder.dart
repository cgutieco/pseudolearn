import '../../domain/model/execution/effect_wait.dart';
import '../../domain/model/execution/execution_step.dart';
import 'rust_effect_gate.dart';
import 'rust_focus_tracker.dart';
import 'rust_wire_models.dart';

final class RustExecutionStepBuilder {
  const RustExecutionStepBuilder();

  ExecutionStep cancelled(int stepNumber) => ExecutionStep(
    stepNumber: stepNumber,
    scopeName: 'global',
    scopeDepth: 1,
    isHalted: true,
    haltReason: 'cancelled',
  );

  ExecutionStep build({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    EffectWait? pending,
    bool finished = false,
    bool halted = false,
    bool awaitingInput = false,
    String? prompt,
    String? reason,
  }) {
    return ExecutionStep(
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
      haltReason: reason,
      isAwaitingInput: awaitingInput,
      inputPrompt: prompt,
      pendingEffect: pending,
    );
  }

  ExecutionStep terminal({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
    required RustTerminationKind termination,
    required RustBatch? batch,
    required String? inputPrompt,
    required String? failureReason,
  }) => switch (termination) {
    RustTerminationKind.completed => _finished(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
    ),
    RustTerminationKind.awaitingInput => build(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
      awaitingInput: true,
      prompt: inputPrompt,
    ),
    RustTerminationKind.awaitingEffect => _awaitingEffect(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
      batch: batch,
    ),
    RustTerminationKind.limitReached => build(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
    ).asStepLimitReached(),
    _ => build(
      tracker: tracker,
      stepNumber: stepNumber,
      eventIndex: eventIndex,
      halted: true,
      reason: failureReason ?? batch?.failureMessage ?? batch?.failureCode,
    ),
  };

  ExecutionStep _finished({
    required RustFocusTracker tracker,
    required int stepNumber,
    required int eventIndex,
  }) => build(
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
