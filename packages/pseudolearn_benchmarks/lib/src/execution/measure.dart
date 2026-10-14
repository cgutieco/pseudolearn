import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../model/run_sample.dart';
import 'counting_observer.dart';

RunResult measureUnobserved(
  AnalyzedProgram program,
  String expectedOutput, {
  int maximumSteps = 10000000,
  List<String> inputs = const [],
}) => _measure(program, expectedOutput, maximumSteps, (null, inputs));

RunResult measureObserved(
  AnalyzedProgram program,
  String expectedOutput, {
  int maximumSteps = 10000000,
  List<String> inputs = const [],
}) => _measure(program, expectedOutput, maximumSteps, (
  CountingObserver(),
  inputs,
));

RunResult _measure(
  AnalyzedProgram program,
  String expectedOutput,
  int maximumSteps,
  (CountingObserver?, List<String>) configuration,
) => _Execution(
  configuration.$2,
  configuration.$1,
).run(program, expectedOutput, maximumSteps);

final class _Execution {
  final Iterator<String> pending;
  final CountingObserver? observer;
  final output = StringBuffer();
  final stopwatch = Stopwatch();

  _Execution(List<String> inputs, this.observer) : pending = inputs.iterator;

  RunResult run(AnalyzedProgram program, String expected, int maximumSteps) {
    final start = Interpreter.start(
      program: program,
      observer: observer,
      random: SeededRandomSource(42),
    );
    if (start is! ExecutionReady) return const RunFailure('start failed');
    stopwatch.start();
    for (var steps = 1; steps <= maximumSteps; steps++) {
      final outcome = start.interpreter.step();
      if (outcome is StepFinished) return finish(expected, steps);
      if (outcome is StepHalted) return const RunFailure('execution halted');
      if (outcome is StepAwaitingInput) {
        if (!pending.moveNext()) {
          return const RunFailure('unexpected input request');
        }
        start.interpreter.provideInput(pending.current);
      }
      if (outcome is StepAdvanced) {
        for (final event in outcome.events.whereType<OutputProducedEvent>()) {
          output.write(event.text);
        }
      }
    }
    return const RunFailure('step limit exceeded');
  }

  RunResult finish(String expected, int steps) {
    stopwatch.stop();
    if (output.toString().trim() != expected) {
      return RunFailure('unexpected output: ${output.toString().trim()}');
    }
    return RunSample(
      steps: steps,
      elapsedMicroseconds: stopwatch.elapsedMicroseconds,
      events: observer?.events ?? 0,
    );
  }
}
