import 'package:pseudolearn_core/pseudolearn_core.dart';

import 'analysis.dart';
import 'diagnostic_observer.dart';

Map<String, Object?> execute(
    Map<String, Object?> request, ReferenceAnalysis analysis) {
  final program = analysis.program;
  final response = <String, Object?>{
    'kind': 'execute',
    ...analysis.response,
    'output': '',
    'termination': {'kind': 'failed', 'code': 'analysisFailed'},
    'events': <Object?>[],
    'states': <Object?>[],
  };
  if (program == null || program.hasErrors) return response;
  if (request['observe'] != 'none') {
    throw const FormatException('Observation unsupported');
  }
  final seed = request['seed'];
  final inputs = request['inputs'];
  final limits = request['limits'];
  if (seed is! int ||
      inputs is! List<Object?> ||
      inputs.any((input) => input is! String) ||
      limits is! Map<String, Object?>) {
    throw const FormatException('Invalid execution arguments');
  }
  final maximum = limits['micro_steps'];
  if (maximum is! int || maximum < 1 || maximum > 1000000) {
    throw const FormatException('Invalid micro-step limit');
  }
  final diagnostics = response['diagnostics']! as List<Map<String, Object?>>;
  final start = Interpreter.start(
      program: program,
      random: SeededRandomSource(seed),
      observer: ReferenceDiagnosticObserver(diagnostics));
  if (start is! ExecutionReady) return response;
  return run(start.interpreter, inputs.cast<String>(), maximum, response);
}

Map<String, Object?> run(Interpreter interpreter, List<String> inputs,
    int maximum, Map<String, Object?> response) {
  final output = StringBuffer();
  final iterator = inputs.iterator;
  for (var steps = 0; steps < maximum; steps++) {
    final outcome = interpreter.step();
    if (outcome is StepAdvanced) {
      for (final event in outcome.events) {
        if (event is OutputProducedEvent) output.write(event.text);
      }
    }
    if (outcome is StepAwaitingInput) {
      if (!iterator.moveNext()) {
        return finish(response, output, {'kind': 'awaiting_input'});
      }
      interpreter.provideInput(iterator.current);
    }
    if (outcome is StepHalted) {
      return finish(response, output,
          {'kind': 'failed', 'code': outcome.diagnostic.code.name});
    }
    if (outcome is StepFinished) {
      return finish(response, output, {'kind': 'completed'});
    }
  }
  return finish(
      response, output, {'kind': 'limit_reached', 'limit': 'micro_steps'});
}

Map<String, Object?> finish(Map<String, Object?> response, StringBuffer output,
        Map<String, Object?> termination) =>
    {
      ...response,
      'output': output.toString(),
      'termination': termination,
    };
