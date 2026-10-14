import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../model/run_sample.dart';
import 'counting_observer.dart';

RunResult measureUnobserved(
  AnalyzedProgram program,
  String expectedOutput, {
  int maximumSteps = 10000000,
}) => _measure(program, expectedOutput, maximumSteps, null);

RunResult measureObserved(
  AnalyzedProgram program,
  String expectedOutput, {
  int maximumSteps = 10000000,
}) => _measure(program, expectedOutput, maximumSteps, CountingObserver());

RunResult _measure(
  AnalyzedProgram program,
  String expectedOutput,
  int maximumSteps,
  CountingObserver? observer,
) {
  final start = Interpreter.start(
    program: program,
    observer: observer,
    random: SeededRandomSource(42),
  );
  if (start is! ExecutionReady) return const RunFailure('start failed');
  final output = StringBuffer();
  final stopwatch = Stopwatch()..start();
  for (var steps = 1; steps <= maximumSteps; steps++) {
    final outcome = start.interpreter.step();
    switch (outcome) {
      case StepAdvanced():
        for (final event in outcome.events.whereType<OutputProducedEvent>()) {
          output.write(event.text);
        }
      case StepFinished():
        stopwatch.stop();
        if (output.toString().trim() != expectedOutput) {
          return RunFailure('unexpected output: ${output.toString().trim()}');
        }
        return RunSample(
          steps: steps,
          elapsedMicroseconds: stopwatch.elapsedMicroseconds,
          events: observer?.events ?? 0,
        );
      case StepHalted():
        return const RunFailure('execution halted');
      case StepAwaitingInput():
        return const RunFailure('unexpected input request');
    }
  }
  return const RunFailure('step limit exceeded');
}
