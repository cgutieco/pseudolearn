import '../../domain/model/execution/execution_step.dart';
import '../../domain/ports/program_execution.dart';
import 'step_settlement.dart';

final class StepBatchRunner {
  static const int defaultBatchSize = 25;
  static const int maxTotalSteps = 10000;
  static const int warningStepThreshold = 9000;

  final int batchSize;
  final int maxSteps;

  const StepBatchRunner({
    this.batchSize = defaultBatchSize,
    this.maxSteps = maxTotalSteps,
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
      final step = execution.step();
      onStep(step);
      final settles = settlement.settlesOn(step, previousRevision);
      previousRevision = step.focusRevision;
      if (settles) return;
      if (step.stepNumber >= maxSteps) {
        onStep(step.asStepLimitReached());
        return;
      }
      stepsInBatch++;
      if (stepsInBatch < batchSize) continue;
      stepsInBatch = 0;
      await Future<void>.delayed(Duration.zero);
    }
  }
}
