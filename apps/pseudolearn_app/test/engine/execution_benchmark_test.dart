import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/step_batch_runner.dart';
import 'package:pseudolearn_app/application/execution/step_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';

void main() {
  group('CIE-F2 · Execution Performance Benchmark (Mid-Range Device Budget)', () {
    const calculationLoop = '''
Proceso Benchmark
  Definir i Como Entero
  i <- 500
  Mientras i > 0 Hacer
    i <- i - 1
  FinMientras
FinProceso
''';

    test('1,000+ steps batch run performance measurement', () async {
      final execution = CoreProgramExecution();
      const runner = StepBatchRunner(batchSize: 25, maxSteps: 10000);

      execution.startExecution(
        sourceCode: calculationLoop,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      final stepsExecuted = <ExecutionStep>[];
      final stopwatch = Stopwatch()..start();

      await runner.runUntilSettled(
        execution,
        settlement: const StepSettlement.atExecutionEnd(),
        fromRevision: 0,
        shouldStop: () => false,
        onStep: stepsExecuted.add,
      );

      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      final stepCount = stepsExecuted.length;

      expect(stepsExecuted.last.isFinished, isTrue);
      expect(stepCount, greaterThanOrEqualTo(1000));
      expect(elapsedMs, lessThan(1000), reason: 'Executing $stepCount steps took ${elapsedMs}ms');

      final averageMsPerBatch = elapsedMs / (stepCount / 25);
      expect(averageMsPerBatch, lessThan(5.0), reason: 'Average time per 25-step batch was ${averageMsPerBatch}ms (budget is 16.6ms for 60fps)');
    });

    test('10,000 steps step budget exhaustion performance', () async {
      const infiniteLoop = '''
Proceso Loop10k
  Definir count Como Entero
  count <- 0
  Mientras count >= 0 Hacer
    count <- count + 1
  FinMientras
FinProceso
''';
      final execution = CoreProgramExecution();
      const runner = StepBatchRunner(batchSize: 50, maxSteps: 10000);

      execution.startExecution(
        sourceCode: infiniteLoop,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      var steps = 0;
      ExecutionStep? lastStep;
      final stopwatch = Stopwatch()..start();

      await runner.runUntilSettled(
        execution,
        settlement: const StepSettlement.atExecutionEnd(),
        fromRevision: 0,
        shouldStop: () => false,
        onStep: (step) {
          lastStep = step;
          steps++;
        },
      );

      stopwatch.stop();

      expect(lastStep!.isStepLimitReached, isTrue);
      expect(steps, greaterThanOrEqualTo(10000));
      expect(stopwatch.elapsedMilliseconds, lessThan(2000), reason: '10,000 steps completed in ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
