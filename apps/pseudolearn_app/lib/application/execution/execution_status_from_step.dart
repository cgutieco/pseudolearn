import '../../domain/model/execution/execution_step.dart';
import 'execution_state.dart';

ExecutionStatus executionStatusFromStep(ExecutionStep step) {
  if (step.isUiSafetyLimitReached) {
    return ExecutionStatus.uiSafetyLimitReached;
  }
  if (step.isStepLimitReached) return ExecutionStatus.stepLimitReached;
  if (step.isHalted) return ExecutionStatus.haltedWithError;
  if (step.isFinished) return ExecutionStatus.finishedSuccess;
  if (step.isAwaitingInput) return ExecutionStatus.pausedAwaitingInput;
  if (step.isAwaitingEffect) return ExecutionStatus.pausedAwaitingEffect;
  return ExecutionStatus.running;
}
