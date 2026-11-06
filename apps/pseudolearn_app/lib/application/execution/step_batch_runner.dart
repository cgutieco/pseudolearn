import '../../domain/model/execution/effect_settlement.dart';
import '../../domain/model/execution/execution_polling_policy.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/ports/program_execution.dart';
import 'step_settlement.dart';

final class StepBatchRunner {
  static const int defaultBatchSize = 25;
  static const int maxUiAdvances = 10000;

  final int batchSize;
  final int maxSteps;

  const StepBatchRunner({
    this.batchSize = defaultBatchSize,
    this.maxSteps = maxUiAdvances,
  });

  Future<void> runUntilSettled(
    ProgramExecution execution, {
    required StepSettlement settlement,
    required int fromRevision,
    required bool Function() shouldStop,
    required void Function(ExecutionStep) onStep,
  }) async {
    var previousRevision = fromRevision;
    var stepsInBatch = 0;
    while (!shouldStop()) {
      var step = execution.step();
      if (step.isAwaitingEffect) {
        onStep(step);
        await Future<void>.delayed(ExecutionPollingPolicy.hostPollInterval);
        if (shouldStop()) return;
        step = execution.settleEffect(EffectSettlement.resolve);
        onStep(step);
        if (step.isAwaitingEffect) continue;
      }
      onStep(step);
      final settles = settlement.settlesOn(step, previousRevision);
      previousRevision = step.focusRevision;
      if (settles) return;
      if (step.stepNumber >= maxSteps) {
        onStep(step.asStepLimitReached(isUiSafetyLimitReached: true));
        return;
      }
      stepsInBatch++;
      if (stepsInBatch < batchSize) continue;
      stepsInBatch = 0;
      await Future<void>.delayed(Duration.zero);
    }
  }
}
