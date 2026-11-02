import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/simulated_capabilities.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';

import '../../fakes/native_test_engine.dart';

const String _recoverableFailureProgram = '''
SubProceso Suspendible Wait(queue Como Canal<Entero>)
Segun Aguardar queue.Recibir() Hacer
Nada: Escribir 0;
Algo(value): Escribir value;
FinSegun
FinSubProceso
SubProceso Suspendible Fail() Como Resultado<Entero, Cadena>
Retornar Error("problem");
FinSubProceso
Algoritmo Main
Definir queue Como Canal<Entero> <- Canal(1);
Tareas failureReport
Lanzar Wait(queue);
Lanzar Fail();
FinTareas
Descartar failureReport;
FinAlgoritmo
''';

const String _trapProgram = '''
SubProceso Suspendible Wait(queue Como Canal<Entero>)
Segun Aguardar queue.Recibir() Hacer
Nada: Escribir 0;
Algo(value): Escribir value;
FinSegun
FinSubProceso
SubProceso Suspendible Crash()
Diferir
Escribir "cleanup";
FinDiferir
Definir Mutable denominator Como Entero <- 1;
denominator <- denominator - 1;
Escribir 1 div denominator;
FinSubProceso
Algoritmo Main
Definir queue Como Canal<Entero> <- Canal(1);
Tareas
Lanzar Wait(queue);
Lanzar Crash();
FinTareas
FinAlgoritmo
''';

const String _nestedEffectCancellationProgram = '''
SubProceso Suspendible Wait()
Diferir
Escribir "cleanup";
FinDiferir
Escribir "before";
Descartar Aguardar SolicitarTemporizador();
FinSubProceso
SubProceso Suspendible Parent()
Diferir
Escribir "parent-cleanup";
FinDiferir
Tareas
Lanzar Wait();
FinTareas
FinSubProceso
Algoritmo P
Tareas
Lanzar Parent();
FinTareas
FinAlgoritmo
''';

void main() {
  tearDownAll(closeTestEngine);

  test('retains recoverable error and cancelled sibling outcomes', () {
    final step = _execute(_recoverableFailureProgram);
    final tasks = _tasks(step);

    expect(step.isFinished, isTrue);
    expect(tasks[0]!.status, ExecutionTaskStatus.completed);
    expect(tasks[1]!.status, ExecutionTaskStatus.cancelled);
    expect(tasks[1]!.completionOutcome, 'cancelled');
    expect(tasks[2]!.status, ExecutionTaskStatus.completed);
    expect(tasks[2]!.completionOutcome, 'error');
  });

  test('marks trap owner and interrupted sibling without running cleanups', () {
    final execution = nativeTestEngine.createProgramExecution();
    var step = _start(execution, _trapProgram);
    for (var count = 0; !step.isTerminal; count++) {
      if (count == 4096) break;
      step = execution.step();
    }
    expect(step.isHalted, isTrue);
    expect(execution.outputLines, isEmpty);

    final tasks = _tasks(step);
    expect(tasks[0]!.status, ExecutionTaskStatus.failed);
    expect(tasks[1]!.status, ExecutionTaskStatus.interruptedByFailure);
    expect(tasks[2]!.status, ExecutionTaskStatus.failed);
  });

  test('marks host cancellation separately and skips task cleanups', () {
    final execution = RustProgramExecution(
      testTransport,
      capabilities: const SimulatedCapabilities(permissions: {'temporizador'}),
      autoResolveEffects: false,
    );
    var step = _start(execution, _nestedEffectCancellationProgram);
    for (var count = 0; !step.isAwaitingEffect && !step.isTerminal; count++) {
      if (count == 4096) break;
      step = execution.step();
    }
    expect(
      step.isAwaitingEffect,
      isTrue,
      reason: 'terminal=${step.isTerminal}, reason=${step.haltReason}',
    );

    step = execution.settleEffect(EffectSettlement.cancel);

    final tasks = _tasks(step);
    expect(step.isCancelled, isTrue);
    expect(step.isHalted, isFalse);
    expect(tasks[0]!.status, ExecutionTaskStatus.cancelledByHost);
    expect(tasks[1]!.status, ExecutionTaskStatus.interruptedByHost);
    expect(tasks[2]!.status, ExecutionTaskStatus.interruptedByHost);
    expect(execution.outputLines.map((line) => line.text), ['before']);
    expect(execution.recordedTape?.toDocument()['status'], 'incomplete');
    expect(execution.projection.termination, 'cancelled');
  });
}

ExecutionStep _execute(String sourceCode) {
  final execution = nativeTestEngine.createProgramExecution();
  var step = _start(execution, sourceCode);
  for (var count = 0; !step.isTerminal; count++) {
    if (count == 4096) break;
    step = execution.step();
  }
  expect(step.isTerminal, isTrue);
  return step;
}

ExecutionStep _start(ProgramExecution execution, String sourceCode) =>
    execution.startExecution(
      sourceCode: sourceCode,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

Map<int, ExecutionTaskContext> _tasks(ExecutionStep step) => {
  for (final task in step.taskContexts) task.taskId: task,
};
