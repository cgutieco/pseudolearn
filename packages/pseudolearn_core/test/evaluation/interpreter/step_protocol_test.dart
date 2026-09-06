import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void _runToCompletion(Interpreter interpreter) {
  var outcome = interpreter.step();
  while (outcome is! StepFinished) {
    outcome = interpreter.step();
  }
}

void main() {
  group('Zero observers costs nothing', () {
    test('running with no observer at all completes normally', () {
      const src = '''
Proceso Principal
    Escribir "hola"
FinProceso
''';
      final interpreter = readyInterpreter(src);
      _runToCompletion(interpreter);
    });

    test('snapshots are only built when an observer is connected', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    x <- 1
FinProceso
''';
      final withoutObserver = readyInterpreter(src);
      var outcome = withoutObserver.step();
      while (outcome is! StepFinished) {
        expect(withoutObserver.snapshotIfObserved(), isNull);
        outcome = withoutObserver.step();
      }

      final withObserver =
          readyInterpreter(src, observer: RecordingExecutionObserver());
      expect(withObserver.snapshotIfObserved(), isNotNull);
    });
  });

  group('Several observers, same order', () {
    test(
        'two independently-run interpreters with recording observers see the same event shape',
        () {
      const src = '''
Proceso Principal
    Escribir "a"
    Escribir "b"
FinProceso
''';
      final program = analyzeProgram(src);
      final first = RecordingExecutionObserver();
      final second = RecordingExecutionObserver();
      final interpreterA = (Interpreter.start(program: program, observer: first)
              as ExecutionReady)
          .interpreter;
      final interpreterB =
          (Interpreter.start(program: program, observer: second)
                  as ExecutionReady)
              .interpreter;
      _runToCompletion(interpreterA);
      _runToCompletion(interpreterB);

      expect(first.events.length, equals(second.events.length));
      for (var i = 0; i < first.events.length; i++) {
        expect(
            first.events[i].runtimeType, equals(second.events[i].runtimeType));
      }
    });
  });
}
