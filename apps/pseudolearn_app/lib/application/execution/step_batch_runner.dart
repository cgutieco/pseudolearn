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
  final Duration yieldBudget;

  const StepBatchRunner({
    this.batchSize = defaultBatchSize,
    this.maxSteps = maxUiAdvances,
    this.yieldBudget = ExecutionPollingPolicy.interfaceYieldBudget,
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
    final sinceYield = Stopwatch()..start();
    while (!shouldStop()) {
      final step = await _settledStep(execution, shouldStop, onStep);
      if (step == null) return;
      onStep(step);
      final settles = settlement.settlesOn(step, previousRevision);
      previousRevision = step.focusRevision;
      if (settles) return;
      if (step.stepNumber >= maxSteps) {
        onStep(step.asStepLimitReached(isUiSafetyLimitReached: true));
        return;
      }
      stepsInBatch++;
      if (stepsInBatch < batchSize && sinceYield.elapsed < yieldBudget) {
        continue;
      }
      stepsInBatch = 0;
      await Future<void>.delayed(Duration.zero);
      sinceYield.reset();
    }
  }

  Future<ExecutionStep?> _settledStep(
    ProgramExecution execution,
    bool Function() shouldStop,
    void Function(ExecutionStep) onStep,
  ) async {
    var step = execution.step();
    if (!step.isAwaitingEffect) return step;
    onStep(step);
    while (step.isAwaitingEffect) {
      await Future<void>.delayed(ExecutionPollingPolicy.hostPollInterval);
      if (shouldStop()) return null;
      step = execution.settleEffect(EffectSettlement.resolve);
    }
    return step;
  }
}
