import 'package:pseudolearn_app/domain/ports/program_execution.dart';
import '../../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/step_batch_runner.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/execution/step_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_tape.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_wait.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/execution/input_wait.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

const _counted = '''
Algoritmo LoopTest
  Definir i Como Entero <- 0;
  Para i <- 1 Hasta 10 Con Paso 1 Hacer
    Escribir i;
  FinPara
FinAlgoritmo
''';

const _endless = '''
Algoritmo Interminable
  Mientras Verdadero Hacer
  FinMientras
FinAlgoritmo
''';

const _tasks = '''
SubProceso Suspendible Work(marker Como Entero)
  Escribir marker;
FinSubProceso
Algoritmo ConTareas
  Tareas
    Lanzar Work(1);
    Lanzar Work(2);
  FinTareas
  Escribir "raiz";
FinAlgoritmo
''';

ProgramExecution _started(String source) {
  final execution = nativeTestEngine.createProgramExecution();
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

    test('stopping between batches emits no later step', () async {
      final steps = <ExecutionStep>[];
      var stop = false;
      await const StepBatchRunner(batchSize: 2).runUntilSettled(
        _started(_counted),
        settlement: _toEnd,
        fromRevision: 0,
        shouldStop: () => stop,
        onStep: (step) {
          steps.add(step);
          if (steps.length == 2) stop = true;
        },
      );

      expect(steps, hasLength(2));
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
        nativeTestEngine.createProgramExecution(),
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

    test('partitions 1, 2, and 25 preserve the complete task trace', () async {
      final traces = <List<int>>[];
      final outputs = <List<String>>[];

      for (final batchSize in [1, 2, 25]) {
        final execution = _started(_tasks);
        final steps = <ExecutionStep>[];
        await StepBatchRunner(batchSize: batchSize).runUntilSettled(
          execution,
          settlement: _toEnd,
          fromRevision: 0,
          shouldStop: () => false,
          onStep: steps.add,
        );
        traces.add([
          for (final step in steps)
            if (!step.isTerminal) step.eventIndex,
        ]);
        outputs.add(execution.outputLines.map((line) => line.text).toList());
      }

      expect(traces[1], traces[0]);
      expect(traces[2], traces[0]);
      expect(outputs[1], outputs[0]);
      expect(outputs[2], outputs[0]);
    });

    test(
      'a pending effect keeps confirmed events visible until the user stops',
      () async {
        final execution = _ScriptedExecution([
          _eventStep(0, 0),
          _eventStep(1, 1),
          _waitingForEffect(2),
        ]);
        final steps = <ExecutionStep>[];

        await const StepBatchRunner(batchSize: 25).runUntilSettled(
          execution,
          settlement: _toEnd,
          fromRevision: 0,
          shouldStop: () => steps.any((step) => step.isAwaitingEffect),
          onStep: steps.add,
        );

        expect(steps.map((step) => step.eventIndex), [0, 1, 2]);
        expect(steps.last.isAwaitingEffect, isTrue);
      },
    );

    test(
      'a task target that never appears reaches the local UI safety cap',
      () async {
        final execution = _ScriptedExecution([
          for (var index = 0; index < 20; index++) _eventStep(index, 1),
        ]);
        final steps = <ExecutionStep>[];

        await const StepBatchRunner(batchSize: 25, maxSteps: 5).runUntilSettled(
          execution,
          settlement: StepSettlement.forTask(
            taskId: 2,
            from: _eventStep(-1, 0),
          ),
          fromRevision: 0,
          shouldStop: () => false,
          onStep: steps.add,
        );

        expect(steps.last.isStepLimitReached, isTrue);
        expect(steps.last.isUiSafetyLimitReached, isTrue);
        expect(steps.last.eventIndex, 4);
        expect(
          _eventStep(4, 1).asStepLimitReached().isUiSafetyLimitReached,
          isFalse,
        );
      },
    );
  });
}

final class _ScriptedExecution implements ProgramExecution {
  final List<ExecutionStep> _steps;
  int _index = 0;

  _ScriptedExecution(this._steps);

  @override
  List<OutputLine> get outputLines => const [];

  @override
  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    ExecutionConfiguration configuration = const ExecutionConfiguration(),
    EffectTape? replayTape,
  }) => _steps.first;

  @override
  ExecutionStep step() => _steps[_index++];

  @override
  ExecutionStep provideInput(InputWait request, String rawInput) => step();

  @override
  ExecutionStep settleEffect(EffectSettlement settlement) => step();

  @override
  void stop() {}
}

ExecutionStep _eventStep(int eventIndex, int taskId) => ExecutionStep(
  stepNumber: eventIndex + 1,
  eventIndex: eventIndex,
  taskId: taskId,
  scopeName: 'task',
  scopeDepth: 1,
);

ExecutionStep _waitingForEffect(int eventIndex) => ExecutionStep(
  stepNumber: eventIndex + 1,
  eventIndex: eventIndex,
  scopeName: 'task',
  scopeDepth: 1,
  pendingEffect: const EffectWait(
    sequence: 1,
    capabilityKind: 'timer',
    operation: 'wait',
    argumentsSummary: '1',
  ),
);
