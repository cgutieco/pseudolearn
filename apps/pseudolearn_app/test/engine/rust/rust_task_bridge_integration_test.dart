import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_window.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_result.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_state.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';
import 'package:pseudolearn_app/domain/model/execution/input_wait.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_execution_resource.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution_observer.dart';

import '../../fakes/recording_rust_transport.dart';

const String spanishProgram = '''
SubProceso Suspendible Wait()
Escribir "before";
Descartar Aguardar SolicitarTemporizador();
Escribir "after";
FinSubProceso
SubProceso Suspendible Work(marker Como Entero)
Escribir marker;
FinSubProceso
Algoritmo P
Tareas
Lanzar Wait();
Lanzar Work(7);
FinTareas
Definir pending Como Entero <- 0;
Leer pending;
Escribir pending;
FinAlgoritmo
''';

const String englishProgram = '''
subroutine suspendable Wait()
write "before";
discard await requestTimer();
write "after";
endSubroutine
subroutine suspendable Work(marker as integer)
write marker;
endSubroutine
algorithm P
tasks
spawn Wait();
spawn Work(7);
endTasks
define pending as integer <- 0;
read pending;
write pending;
endAlgorithm
''';

const int waitingTask = 1;
const int advancingTask = 2;
const int rootTask = 0;
const int stepBound = 400;

final class BridgeScenario {
  final String label;
  final String source;
  final SyntaxProfileId profile;
  final UiLanguageId language;

  const BridgeScenario(this.label, this.source, this.profile, this.language);
}

const List<BridgeScenario> scenarios = [
  BridgeScenario(
    'classic Spanish',
    spanishProgram,
    SyntaxProfileId.classicSpanish,
    UiLanguageId.spanish,
  ),
  BridgeScenario(
    'English',
    englishProgram,
    SyntaxProfileId.english,
    UiLanguageId.english,
  ),
];

final class _Session {
  final RecordingRustTransport transport;
  final RustProgramExecution execution;
  final RustProgramExecutionObserver observer;

  _Session._(this.transport, this.execution, this.observer);

  factory _Session.open() {
    final native = openNativeTransport();
    addTearDown(native.close);
    final transport = RecordingRustTransport(native);
    final resource = RustExecutionResource();
    return _Session._(
      transport,
      RustProgramExecution(
        transport,
        autoResolveEffects: false,
        observationResource: resource,
      ),
      RustProgramExecutionObserver(transport, resource),
    );
  }

  int count(String operation) =>
      transport.operations.where((name) => name == operation).length;
}

ExecutionStep _start(_Session session, BridgeScenario scenario) =>
    session.execution.startExecution(
      sourceCode: scenario.source,
      profileId: scenario.profile,
      languageId: scenario.language,
    );

Future<ExecutionStep> _until(
  _Session session,
  ExecutionStep from,
  bool Function(ExecutionStep step) reached,
) async {
  var step = from;
  for (var count = 0; count < stepBound; count++) {
    if (reached(step) || step.isTerminal) return step;
    await Future<void>.delayed(const Duration(milliseconds: 1));
    step = step.isAwaitingEffect
        ? session.execution.settleEffect(EffectSettlement.resolve)
        : session.execution.step();
  }
  fail('the condition was not reached within $stepBound steps');
}

int _eventIndex(_Session session, String eventClass, int taskId) {
  final window = session.observer.historyWindow(start: 0, count: 200);
  final events = (window as ExecutionObservationValue<ExecutionHistoryWindow>)
      .value
      .events;
  return events
      .firstWhere(
        (event) =>
            event.eventClass == eventClass && event.data['task'] == taskId,
      )
      .index;
}

ExecutionObservationState _state(_Session session, int event, int taskId) {
  final result = session.observer.stateAt(
    event: event,
    taskId: taskId,
    startFrame: 0,
    frameCount: 8,
  );
  expect(result, isA<ExecutionObservationValue<ExecutionObservationState>>());
  return (result as ExecutionObservationValue<ExecutionObservationState>).value;
}

String _stateOf(ExecutionObservationState state, int taskId) =>
    state.tasks.singleWhere((task) => task.taskId == taskId).state;

ExecutionTaskContext _task(ExecutionStep step, int taskId) =>
    step.taskContexts.singleWhere((task) => task.taskId == taskId);

List<String> _lines(_Session session) =>
    session.execution.outputLines.map((line) => line.text).toList();

void main() {
  for (final scenario in scenarios) {
    group('real bridge with tasks · ${scenario.label}', () {
      test(
        'a suspended task is inspected while another one advances',
        () async {
          final session = _Session.open();
          final step = await _until(
            session,
            _start(session, scenario),
            (step) => step.isAwaitingEffect,
          );

          expect(step.isAwaitingEffect, isTrue);
          expect(step.pendingEffect?.operation, 'request_timer');
          expect(_task(step, rootTask).status, ExecutionTaskStatus.suspended);
          expect(
            _task(step, advancingTask).status,
            ExecutionTaskStatus.completed,
          );
          expect(_task(step, waitingTask).status.isTerminal, isFalse);
          expect(_lines(session), ['before', '7']);

          final suspendedAt = _eventIndex(
            session,
            'task_suspended',
            waitingTask,
          );
          final state = _state(session, suspendedAt, waitingTask);
          expect(state.taskId, waitingTask);
          expect(state.frames.map((frame) => frame.name), contains('Wait'));
          expect(_stateOf(state, waitingTask), 'waiting');
          expect(_stateOf(state, advancingTask), isNot('completed'));

          final later = _state(session, step.eventIndex, rootTask);
          expect(_stateOf(later, advancingTask), 'completed');
          expect(_stateOf(later, waitingTask), isNot('waiting'));

          final calls = session.count('advance');
          _state(session, suspendedAt, waitingTask);
          expect(session.count('advance'), calls);
          expect(_lines(session), ['before', '7']);
          session.execution.stop();
        },
      );

      test('an unknown task is a typed result, not an exception', () async {
        final session = _Session.open();
        final step = await _until(
          session,
          _start(session, scenario),
          (step) => step.isAwaitingEffect,
        );

        final missing = session.observer.stateAt(
          event: step.eventIndex,
          taskId: 99,
          startFrame: 0,
          frameCount: 8,
        );
        expect(missing, isNot(isA<ExecutionObservationValue<Object?>>()));
        expect(_lines(session), ['before', '7']);
        session.execution.stop();
      });

      test(
        'resolving the effect resumes the waiting task and then asks for input',
        () async {
          final session = _Session.open();
          final waiting = await _until(
            session,
            _start(session, scenario),
            (step) => step.isAwaitingEffect,
          );
          expect(waiting.isAwaitingEffect, isTrue);

          final resumed = await _until(
            session,
            session.execution.settleEffect(EffectSettlement.resolve),
            (step) => step.isAwaitingInput,
          );

          expect(resumed.isAwaitingInput, isTrue);
          expect(resumed.inputWait?.taskId, rootTask);
          expect(_lines(session), ['before', '7', 'after']);
          expect(
            _task(resumed, waitingTask).status,
            ExecutionTaskStatus.completed,
          );
          session.execution.stop();
        },
      );

      test(
        'stale and foreign input is rejected before it reaches the engine',
        () async {
          final session = _Session.open();
          var step = await _until(
            session,
            _start(session, scenario),
            (step) => step.isAwaitingEffect,
          );
          step = await _until(
            session,
            session.execution.settleEffect(EffectSettlement.resolve),
            (step) => step.isAwaitingInput,
          );
          final real = step.inputWait!;
          final inputCalls = session.count('input');

          final stale = InputWait(
            resourceId: real.resourceId,
            taskId: real.taskId,
            requestId: real.requestId + 1,
          );
          final foreign = InputWait(
            resourceId: real.resourceId,
            taskId: waitingTask,
            requestId: real.requestId,
          );
          final other = InputWait(
            resourceId: real.resourceId + 1,
            taskId: real.taskId,
            requestId: real.requestId,
          );
          for (final request in [stale, foreign, other]) {
            final answered = session.execution.provideInput(request, '5');
            expect(answered.isAwaitingInput, isTrue);
          }

          expect(session.count('input'), inputCalls);
          expect(_lines(session), ['before', '7', 'after']);

          final finished = session.execution.provideInput(real, '5');
          final end = await _until(
            session,
            finished,
            (step) => step.isFinished,
          );
          expect(end.isFinished, isTrue);
          final expected = ['before', '7', 'after', '5', '5'];
          expect(_lines(session), expected);
          session.execution.provideInput(real, '6');
          expect(_lines(session), expected);
          session.execution.stop();
        },
      );

      test('cancelling releases every engine resource it opened', () async {
        final session = _Session.open();
        final waiting = await _until(
          session,
          _start(session, scenario),
          (step) => step.isAwaitingEffect,
        );
        expect(waiting.isAwaitingEffect, isTrue);

        final cancelled = session.execution.settleEffect(
          EffectSettlement.cancel,
        );

        expect(cancelled.isCancelled, isTrue);
        expect(cancelled.isHalted, isFalse);
        expect(
          _task(cancelled, waitingTask).status,
          ExecutionTaskStatus.interruptedByHost,
        );
        expect(
          session.execution.recordedTape?.toDocument()['status'],
          'incomplete',
        );
        final opened =
            session.count('create_analysis') + session.count('start');
        session.execution.stop();
        expect(session.count('release'), opened);
      });

      test(
        'stopping a finished run releases its resources exactly once',
        () async {
          final session = _Session.open();
          var step = await _until(
            session,
            _start(session, scenario),
            (step) => step.isAwaitingEffect,
          );
          step = await _until(
            session,
            session.execution.settleEffect(EffectSettlement.resolve),
            (step) => step.isAwaitingInput,
          );
          await _until(
            session,
            session.execution.provideInput(step.inputWait!, '1'),
            (step) => step.isFinished,
          );
          final opened =
              session.count('create_analysis') + session.count('start');
          session.execution.stop();
          session.execution.stop();
          expect(session.count('release'), opened);
        },
      );
    });
  }

  test(
    'an unknown operation and a malformed class never reach the app model',
    () async {
      final session = _Session.open();
      expect(
        () => session.transport.call('no_such_operation', const {}),
        throwsA(anything),
      );
      final step = session.execution.startExecution(
        sourceCode: 'Algoritmo',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(step.isTerminal, isTrue);
      expect(step.isFinished, isFalse);
    },
  );
}
