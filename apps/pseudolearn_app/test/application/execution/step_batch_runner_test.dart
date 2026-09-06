import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/step_batch_runner.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/execution/step_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';

const _counted = '''
Algoritmo LoopTest
  Definir i Como Entero
  Para i <- 1 Hasta 10 Con Paso 1 Hacer
    Escribir i
  FinPara
FinAlgoritmo
''';

const _endless = '''
Algoritmo Interminable
  Mientras Verdadero Hacer
  FinMientras
FinAlgoritmo
''';

CoreProgramExecution _started(String source) {
  final execution = CoreProgramExecution();
  execution.startExecution(
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  return execution;
}

const _toEnd = StepSettlement.atExecutionEnd();
const _anyFocusChange = StepSettlement.atAnyFocusChange();

void main() {
  group('StepBatchRunner', () {
    test('runs in batches until the program finishes', () async {
      final steps = <ExecutionStep>[];
      await const StepBatchRunner(batchSize: 5).runUntilSettled(
        _started(_counted),
        settlement: _toEnd,
        fromRevision: 0,
        shouldStop: () => false,
        onStep: steps.add,
      );

      expect(steps.last.isFinished, isTrue);
      expect(steps.length, greaterThan(10));
    });

    test('a single didactic step stops at the first focus change', () async {
      final steps = <ExecutionStep>[];
      await const StepBatchRunner(batchSize: 5).runUntilSettled(
        _started(_counted),
        settlement: _anyFocusChange,
        fromRevision: 0,
        shouldStop: () => false,
        onStep: steps.add,
      );

      expect(steps.last.focusRevision, equals(1));
      expect(steps.last.isFinished, isFalse);
    });

    test('stopping mid-run emits no step after the request', () async {
      final steps = <ExecutionStep>[];
      var stop = false;
      await const StepBatchRunner(batchSize: 5).runUntilSettled(
        _started(_counted),
        settlement: _toEnd,
        fromRevision: 0,
        shouldStop: () => stop,
        onStep: (step) {
          steps.add(step);
          if (steps.length == 4) stop = true;
        },
      );

      expect(steps, hasLength(4));
      expect(steps.last.isFinished, isFalse);
    });

    test('a program that never advances trips the step limit', () async {
      final steps = <ExecutionStep>[];
      await const StepBatchRunner(batchSize: 5, maxSteps: 40).runUntilSettled(
        _started(_endless),
        settlement: _toEnd,
        fromRevision: 0,
        shouldStop: () => false,
        onStep: steps.add,
      );

      expect(steps.last.isStepLimitReached, isTrue);
      expect(steps.last.isTerminal, isTrue);
    });

    test('an execution that never started settles at once', () async {
      final steps = <ExecutionStep>[];
      await const StepBatchRunner(batchSize: 5).runUntilSettled(
        CoreProgramExecution(),
        settlement: _toEnd,
        fromRevision: 0,
        shouldStop: () => false,
        onStep: steps.add,
      );

      expect(steps, hasLength(1));
      expect(steps.single.isFinished, isTrue);
    });

    test('a block skipped whole never rests inside the loop', () async {
      final execution = _started(_counted);
      final steps = <ExecutionStep>[];
      await const StepBatchRunner(batchSize: 5).runUntilSettled(
        execution,
        settlement: _anyFocusChange,
        fromRevision: 0,
        shouldStop: () => false,
        onStep: steps.add,
      );
      final atHeader = steps.last;
      await const StepBatchRunner(batchSize: 5).runUntilSettled(
        execution,
        settlement: StepSettlement.forPace(StepPace.nextStatement, atHeader),
        fromRevision: atHeader.focusRevision,
        shouldStop: () => false,
        onStep: steps.add,
      );

      expect(steps.last.focusRevision, greaterThan(atHeader.focusRevision));
    });
  });
}
