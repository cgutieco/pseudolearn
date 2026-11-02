import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/execution_status_from_step.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_wait.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';

ExecutionStep step({
  bool finished = false,
  bool halted = false,
  bool stepLimit = false,
  bool uiLimit = false,
  bool awaitingInput = false,
  bool awaitingEffect = false,
}) => ExecutionStep(
  stepNumber: 1,
  scopeName: 'global',
  scopeDepth: 1,
  isFinished: finished,
  isHalted: halted,
  isStepLimitReached: stepLimit,
  isUiSafetyLimitReached: uiLimit,
  isAwaitingInput: awaitingInput,
  pendingEffect: awaitingEffect
      ? const EffectWait(
          sequence: 1,
          capabilityKind: 'host',
          operation: 'clock_now',
          argumentsSummary: '',
        )
      : null,
);

void main() {
  test('maps an ordinary step to running', () {
    expect(executionStatusFromStep(step()), ExecutionStatus.running);
  });

  test('keeps engine and UI limits distinct', () {
    expect(
      executionStatusFromStep(step(stepLimit: true)),
      ExecutionStatus.stepLimitReached,
    );
    expect(
      executionStatusFromStep(step(uiLimit: true, stepLimit: true)),
      ExecutionStatus.uiSafetyLimitReached,
    );
  });

  test('maps terminal and waiting states', () {
    expect(
      executionStatusFromStep(step(halted: true)),
      ExecutionStatus.haltedWithError,
    );
    expect(
      executionStatusFromStep(step(finished: true)),
      ExecutionStatus.finishedSuccess,
    );
    expect(
      executionStatusFromStep(step(awaitingInput: true)),
      ExecutionStatus.pausedAwaitingInput,
    );
    expect(
      executionStatusFromStep(step(awaitingEffect: true)),
      ExecutionStatus.pausedAwaitingEffect,
    );
  });
}
