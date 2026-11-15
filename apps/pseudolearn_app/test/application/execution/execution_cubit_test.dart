import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import '../../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_history_command.dart';
import 'package:pseudolearn_app/application/execution/execution_history_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_batch_runner.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/execution/input_wait.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/engine/execution/task_flow_projection.dart';
import 'package:pseudolearn_app/engine/execution/task_structure_projection.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import '../../fakes/fake_program_execution.dart';

const _counted = '''
Algoritmo Contado
  Definir i Como Entero <- 0;
  Para i <- 1 Hasta 3 Con Paso 1 Hacer
    Escribir i;
  FinPara
FinAlgoritmo
''';

const _immediate = '''
Algoritmo Rapido
  Escribir "Listo";
FinAlgoritmo
''';

const _broken = '''
Algoritmo Roto
  Definir x Como Entero <- 0;
  x <-
FinAlgoritmo
''';

const _loop = '''
Algoritmo Bucle
  Definir i Como Entero <- 0;
  Definir t Como Entero <- 0;
  t <- 0;
  Para i <- 1 Hasta 3 Con Paso 1 Hacer
    t <- t + i;
  FinPara
  Escribir t;
FinAlgoritmo
''';

const _readsInput = '''
Algoritmo Pide
  Definir n Como Entero <- 0;
  Leer n;
  Escribir n;
FinAlgoritmo
''';

const _endless = '''
Algoritmo Interminable
  Mientras Verdadero Hacer
  FinMientras
FinAlgoritmo
''';

const _taskProgram = '''
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

final class _StoppingExecution extends FakeProgramExecution {
  final void Function(int calls) onStep;
  int calls = 0;

  _StoppingExecution(this.onStep);

  @override
  ExecutionStep step() {
    calls++;
    onStep(calls);
    return ExecutionStep(stepNumber: calls, scopeName: 'global', scopeDepth: 1);
  }
}

extension on ExecutionCubit {
  Future<void> step() => advance(
    pace: StepPace.nextStatement,
    sourceCode: _counted,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );

  Future<void> pace(StepPace pace, String source) => advance(
    pace: pace,
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );

  Future<void> runToEnd(String source) => advance(
    pace: StepPace.toEnd,
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
}

void main() {
  test('replay without a tape never starts a live execution', () async {
    final execution = FakeProgramExecution();
    final cubit = ExecutionCubit(execution: execution);
    await cubit.advance(
      pace: StepPace.toEnd,
      sourceCode: _immediate,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      replay: true,
    );
    expect(execution.lastConfiguration, isNull);
    expect(cubit.state.replayRejection, ReplayRejection.missingTape);
    await cubit.close();
  });

  group('ExecutionCubit', () {
    late ExecutionCubit cubit;

    setUp(
      () => cubit = ExecutionCubit(
        execution: nativeTestEngine.createProgramExecution(),
      ),
    );
    tearDown(() => cubit.close());

    test('a manual step settles paused, never running', () async {
      await cubit.step();

      expect(cubit.state.status, ExecutionStatus.pausedAtStatement);
      expect(cubit.state.canStart, isTrue);
      expect(cubit.state.isInFlight, isTrue);
    });

    test(
      'each manual step lands on the next statement, not the next task',
      () async {
        final lines = <int?>[];
        for (var i = 0; i < 8; i++) {
          await cubit.step();
          lines.add(cubit.state.currentStep.focus?.startLine);
          if (cubit.state.currentStep.isTerminal) break;
        }

        expect(lines.take(3), [2, 3, 4]);
        expect(cubit.state.statementNumber, greaterThan(0));
      },
    );

    test(
      'a global event step consumes one event without waiting for focus',
      () async {
        await cubit.pace(StepPace.nextEvent, _counted);
        final firstEvent = cubit.state.currentStep.eventIndex;
        await cubit.pace(StepPace.nextEvent, _counted);

        expect(firstEvent, 0);
        expect(cubit.state.currentStep.eventIndex, firstEvent + 1);
      },
    );

    test(
      'concurrent event commands are serialized in submission order',
      () async {
        await Future.wait([
          cubit.pace(StepPace.nextEvent, _counted),
          cubit.pace(StepPace.nextEvent, _counted),
        ]);

        expect(cubit.state.currentStep.eventIndex, 1);
        expect(cubit.state.currentStep.stepNumber, 2);
      },
    );

    test(
      'a task step applies intervening events until the selected task runs',
      () async {
        await _advanceUntilTaskExists(cubit, 2);
        final firstEvent = cubit.state.currentStep.eventIndex;
        final seenTaskIds = <int>[];
        final subscription = cubit.stream.listen(
          (state) => seenTaskIds.add(state.currentStep.taskId),
        );

        await cubit.advanceTask(taskId: 2);
        await subscription.cancel();

        expect(cubit.state.currentStep.eventIndex, greaterThan(firstEvent));
        expect(cubit.state.currentStep.taskId, 2);
        expect(seenTaskIds, contains(1));
        expect(cubit.state.outputLines.map((line) => line.text), contains('1'));
        expect(cubit.state.status, ExecutionStatus.pausedAtStatement);
      },
    );

    test('missing and completed tasks leave execution unchanged', () async {
      await cubit.pace(StepPace.nextEvent, _taskProgram);
      final running = cubit.state;
      await cubit.advanceTask(taskId: 99);
      expect(cubit.state, same(running));

      await cubit.pace(StepPace.toEnd, _taskProgram);
      final finished = cubit.state;
      await cubit.advanceTask(taskId: 1);

      expect(cubit.state, same(finished));
    });

    test(
      'the counter counts statements, far below the interpreter tasks',
      () async {
        await cubit.runToEnd(_counted);

        expect(cubit.state.status, ExecutionStatus.finishedSuccess);
        expect(
          cubit.state.statementNumber,
          lessThan(cubit.state.currentStep.stepNumber),
        );
        expect(cubit.state.statementNumber, greaterThan(0));
      },
    );

    test('twenty consecutive manual steps all advance', () async {
      var lastStepNumber = -1;
      for (var i = 0; i < 20; i++) {
        await cubit.step();
        if (cubit.state.currentStep.isTerminal) break;
        expect(cubit.state.canStart, isTrue);
        expect(cubit.state.currentStep.stepNumber, greaterThan(lastStepNumber));
        lastStepNumber = cubit.state.currentStep.stepNumber;
      }
      expect(lastStepNumber, greaterThan(10));
    });

    test('running to the end reaches success and produces output', () async {
      await cubit.runToEnd(_immediate);

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.outputLines, isNotEmpty);
      expect(cubit.state.isInFlight, isFalse);
    });

    test('stop settles idle and never reports success', () async {
      await cubit.step();
      cubit.stop();

      expect(cubit.state.status, ExecutionStatus.idle);
      expect(cubit.state.currentStep.focus, isNull);
      expect(cubit.state.isInFlight, isFalse);
    });

    test('a stop issued during a pump ends it at the next yield', () async {
      late final ExecutionCubit local;
      final execution = _StoppingExecution((calls) {
        if (calls == 3) Future<void>(local.stop);
      });
      local = ExecutionCubit(execution: execution);
      addTearDown(local.close);

      await local.runToEnd(_immediate);

      expect(execution.calls, StepBatchRunner.defaultBatchSize);
      expect(execution.isStopped, isTrue);
      expect(local.state.status, ExecutionStatus.idle);
    });

    test('a start queued before a stop never reaches the engine', () async {
      final execution = _StoppingExecution((_) {});
      final local = ExecutionCubit(execution: execution);
      addTearDown(local.close);

      final queued = local.runToEnd(_immediate);
      local.stop();
      await queued;

      expect(execution.calls, 0);
      expect(local.state.status, ExecutionStatus.idle);
    });

    test('keeps document execution configuration when starting', () async {
      final execution = FakeProgramExecution();
      final local = ExecutionCubit(execution: execution);
      addTearDown(local.close);
      const configuration = ExecutionConfiguration(
        documentId: 'doc',
        arguments: ['á b', ''],
      );
      await local.advance(
        pace: StepPace.nextStatement,
        sourceCode: _counted,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
        configuration: configuration,
      );
      expect(execution.lastConfiguration, configuration);
      expect(local.state.configuration, configuration);
    });

    test('a program that does not analyse halts without starting', () async {
      await cubit.runToEnd(_broken);

      expect(cubit.state.status, ExecutionStatus.haltedWithError);
    });

    test('an empty program halts instead of hanging', () async {
      await cubit.runToEnd('');

      expect(cubit.state.status, ExecutionStatus.haltedWithError);
    });

    test('each start raises the run identifier', () async {
      await cubit.step();
      final first = cubit.state.runId;
      cubit.stop();
      await cubit.step();

      expect(cubit.state.runId, greaterThan(first));
    });

    test(
      'a program awaiting input pauses and resumes with the value',
      () async {
        await cubit.runToEnd(_readsInput);
        expect(cubit.state.status, ExecutionStatus.pausedAwaitingInput);
        expect(cubit.state.canStart, isFalse);

        await cubit.provideInput(cubit.state.currentStep.inputWait!, '7');

        expect(cubit.state.status, ExecutionStatus.finishedSuccess);
        expect(cubit.state.outputLines.map((line) => line.text), contains('7'));
      },
    );

    test('providing input without an execution changes nothing', () async {
      final before = cubit.state;
      await cubit.provideInput(
        const InputWait(resourceId: 0, taskId: 0, requestId: 1),
        '7',
      );

      expect(cubit.state, before);
    });

    test('the local UI cap stays distinct from an engine limit', () async {
      final cappedCubit = ExecutionCubit(
        execution: nativeTestEngine.createProgramExecution(),
        runner: const StepBatchRunner(maxSteps: 20),
      );
      addTearDown(cappedCubit.close);

      await cappedCubit.advance(
        pace: StepPace.toEnd,
        sourceCode: _endless,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(cappedCubit.state.status, ExecutionStatus.uiSafetyLimitReached);
      expect(cappedCubit.state.currentStep.isStepLimitReached, isTrue);
      expect(cappedCubit.state.currentStep.isUiSafetyLimitReached, isTrue);
    });

    test('toggling the output panel records the choice', () {
      cubit.applyViewAction(ExecutionViewAction.toggleOutputPanel);
      expect(cubit.state.isOutputPanelExpanded, isTrue);
      expect(cubit.state.userCollapsedOutput, isFalse);

      cubit.applyViewAction(ExecutionViewAction.toggleOutputPanel);
      expect(cubit.state.isOutputPanelExpanded, isFalse);
      expect(cubit.state.userCollapsedOutput, isTrue);
    });

    test('running to the end with the trace hidden reads no variables', () async {
      await cubit.runToEnd(_loop);

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.outputLines.single.text, '6');
      expect(cubit.state.observesVariables, isFalse);
      expect(cubit.state.currentStep.variables, isEmpty);
    });

    test('running to the end with the trace shown reads variables', () async {
      cubit.applyViewAction(ExecutionViewAction.showTrace);
      await cubit.runToEnd(_loop);

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.isTraceVisible, isTrue);
      expect(cubit.state.observesVariables, isTrue);
      expect(cubit.state.currentStep.variables, isNotEmpty);
    });

    test('a manual step reads variables with the trace hidden', () async {
      await cubit.step();

      expect(cubit.state.isTraceVisible, isFalse);
      expect(cubit.state.observesVariables, isTrue);
    });

    test('showing the trace mid-run starts reading variables', () async {
      await cubit.runToEnd(_readsInput);
      expect(cubit.state.status, ExecutionStatus.pausedAwaitingInput);
      expect(cubit.state.observesVariables, isFalse);

      cubit.applyViewAction(ExecutionViewAction.showTrace);

      expect(cubit.state.observesVariables, isTrue);
      expect(cubit.state.status, ExecutionStatus.pausedAwaitingInput);
    });

    test('running to the end publishes far fewer states than steps', () async {
      final published = <ExecutionState>[];
      final subscription = cubit.stream.listen(published.add);

      await cubit.runToEnd(_loop);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(cubit.state.status, ExecutionStatus.finishedSuccess);
      expect(cubit.state.isContinuous, isTrue);
      expect(
        published.length,
        lessThan(cubit.state.currentStep.stepNumber ~/ 2),
      );
    });

    test('a throttled run counts the same statements as a traced one', () async {
      await cubit.runToEnd(_loop);
      final throttledCount = cubit.state.statementNumber;

      cubit.applyViewAction(ExecutionViewAction.showTrace);
      await cubit.runToEnd(_loop);

      expect(throttledCount, greaterThan(0));
      expect(cubit.state.statementNumber, throttledCount);
    });

    test('a manual step after a run is no longer continuous', () async {
      await cubit.runToEnd(_loop);
      await cubit.step();

      expect(cubit.state.isContinuous, isFalse);
      expect(cubit.state.followedFocus, isNotNull);
    });

    test('stopping a continuous run keeps the output it produced', () async {
      final running = cubit.runToEnd(_endless);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      cubit.stop();
      await running;

      expect(cubit.state.status, ExecutionStatus.idle);
      expect(cubit.state.isContinuous, isTrue);
      expect(cubit.state.isContinuousRun, isFalse);
    });

    test('switching the trace keeps the halt message', () async {
      await cubit.runToEnd(_broken);
      final haltMessage = cubit.state.haltMessage;

      cubit.applyViewAction(ExecutionViewAction.showTrace);
      cubit.applyViewAction(ExecutionViewAction.showOtherTab);

      expect(cubit.state.status, ExecutionStatus.haltedWithError);
      expect(cubit.state.haltMessage, haltMessage);
    });

  });

  group('ExecutionCubit paces', () {
    late ExecutionCubit cubit;

    setUp(
      () => cubit = ExecutionCubit(
        execution: nativeTestEngine.createProgramExecution(),
      ),
    );
    tearDown(() => cubit.close());

    Future<void> stepUntilLine(int line) async {
      for (var i = 0; i < 40; i++) {
        await cubit.pace(StepPace.nextStatement, _loop);
        if (cubit.state.currentStep.focus?.startLine == line) return;
        if (cubit.state.currentStep.isTerminal) break;
      }
      fail('never reached line $line');
    }

    test(
      'global stepping and root-task stepping preserve the same trace end',
      () async {
        final taskExecution = nativeTestEngine.createProgramExecution();
        final taskCubit = ExecutionCubit(execution: taskExecution);
        addTearDown(taskCubit.close);
        final globalExecution = nativeTestEngine.createProgramExecution();
        final globalCubit = ExecutionCubit(execution: globalExecution);
        addTearDown(globalCubit.close);
        final taskEventIndexes = <int>[];
        final globalEventIndexes = <int>[];
        final taskSubscription = taskCubit.stream.listen(
          (state) =>
              _recordEventIndex(taskEventIndexes, state.currentStep.eventIndex),
        );
        final globalSubscription = globalCubit.stream.listen(
          (state) => _recordEventIndex(
            globalEventIndexes,
            state.currentStep.eventIndex,
          ),
        );
        addTearDown(taskSubscription.cancel);
        addTearDown(globalSubscription.cancel);

        await taskCubit.pace(StepPace.nextEvent, _taskProgram);
        await globalCubit.pace(StepPace.nextEvent, _taskProgram);
        await Future<void>.delayed(Duration.zero);
        taskEventIndexes.clear();
        globalEventIndexes.clear();

        for (
          var count = 0;
          count < 200 && !globalCubit.state.currentStep.isTerminal;
          count++
        ) {
          await globalCubit.pace(StepPace.nextEvent, _taskProgram);
        }
        for (
          var count = 0;
          count < 200 && !taskCubit.state.currentStep.isTerminal;
          count++
        ) {
          await taskCubit.advanceTask(taskId: 0);
        }
        await Future<void>.delayed(Duration.zero);

        expect(taskCubit.state.currentStep.isFinished, isTrue);
        expect(
          taskCubit.state.currentStep.eventIndex,
          globalCubit.state.currentStep.eventIndex,
        );
        expect(taskEventIndexes, globalEventIndexes);
        expect(
          taskCubit.state.outputLines.map((line) => line.text),
          globalCubit.state.outputLines.map((line) => line.text),
        );
      },
    );

    test('history reads do not duplicate output or event indexes', () async {
      final session = nativeTestEngine.createObservableExecutionSession();
      final execution = ExecutionCubit(execution: session.execution);
      final history = ExecutionHistoryCubit(
        executionStates: execution.stream,
        observer: session.observer,
        flowProjector: const TaskFlowProjection(),
        structureProjector: const TaskStructureProjection(),
      );
      addTearDown(history.close);
      addTearDown(execution.close);

      await _advanceUntilTaskExists(execution, 2);
      await execution.advanceTask(taskId: 2);
      await execution.advance(
        pace: StepPace.toEnd,
        sourceCode: _taskProgram,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      final output = execution.state.outputLines
          .map((line) => line.text)
          .toList();
      final eventIndexes = history.state.events
          .map((event) => event.index)
          .toList();

      history.dispatch(const FollowCurrentHistoryEvent());

      expect(eventIndexes.toSet().length, eventIndexes.length);
      expect(execution.state.outputLines.map((line) => line.text), output);
      expect(
        history.state.events.map((event) => event.index).toList(),
        eventIndexes,
      );
    });

    test(
      'the loop header is a decision, and only there can a block be skipped',
      () async {
        await stepUntilLine(5);

        expect(cubit.state.currentStep.focus?.isDecision, isTrue);
        expect(cubit.state.canStepOverBlock, isTrue);
      },
    );

    test(
      'a plain statement offers neither skipping nor leaving a block',
      () async {
        await stepUntilLine(2);

        expect(cubit.state.canStepOverBlock, isFalse);
        expect(cubit.state.canStepOutOfBlock, isFalse);
      },
    );

    test(
      'skipping the block runs every turn and lands after the loop',
      () async {
        await stepUntilLine(5);
        await cubit.pace(StepPace.overBlock, _loop);

        expect(cubit.state.currentStep.focus?.startLine, equals(8));
        expect(cubit.state.status, ExecutionStatus.pausedAtStatement);
        expect(
          cubit.state.currentStep.variables.map((row) => row.formattedValue),
          contains('6'),
        );
      },
    );

    test(
      'leaving the block from inside the body lands after the loop',
      () async {
        await stepUntilLine(6);

        expect(cubit.state.canStepOutOfBlock, isTrue);
        await cubit.pace(StepPace.outOfBlock, _loop);

        expect(cubit.state.currentStep.focus?.startLine, equals(8));
      },
    );

    test('the loop comes back to its condition on every turn', () async {
      final lines = <int?>[];
      for (var i = 0; i < 12; i++) {
        await cubit.pace(StepPace.nextStatement, _loop);
        lines.add(cubit.state.currentStep.focus?.startLine);
        if (cubit.state.currentStep.isTerminal) break;
      }

      expect(lines.take(9), [2, 3, 4, 5, 6, 5, 6, 5, 6]);
    });

    test(
      'the statement counter matches the number of didactic steps',
      () async {
        await cubit.pace(StepPace.nextStatement, _loop);
        await cubit.pace(StepPace.nextStatement, _loop);
        await cubit.pace(StepPace.nextStatement, _loop);

        expect(cubit.state.statementNumber, equals(3));
      },
    );
  });
}

Future<void> _advanceUntilTaskExists(ExecutionCubit cubit, int taskId) async {
  for (var count = 0; count < 40; count++) {
    if (cubit.state.currentStep.taskContexts.any(
      (task) => task.taskId == taskId,
    )) {
      return;
    }
    await cubit.pace(StepPace.nextStatement, _taskProgram);
    if (cubit.state.currentStep.isTerminal) break;
  }
  fail('task $taskId was not created');
}

void _recordEventIndex(List<int> indexes, int eventIndex) {
  if (eventIndex < 0 || (indexes.isNotEmpty && indexes.last == eventIndex)) {
    return;
  }
  indexes.add(eventIndex);
}
