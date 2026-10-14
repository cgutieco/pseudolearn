import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';

void main(List<String> arguments) {
  final corpus = File('../pseudolearn_spec/specifications/export.json');
  final workloads = corpusWorkloads(corpus.readAsStringSync());
  if (workloads == null) {
    stderr.writeln('Invalid AWFY corpus');
    exitCode = 1;
    return;
  }
  for (final (workload, inputs) in workloads) {
    if (!_run(workload, inputs, arguments.contains('--verify') ? 1 : 30)) {
      exitCode = 1;
      return;
    }
  }
}

bool _run(Workload workload, List<String> inputs, int iterations) {
  final program = analyze(workload.source);
  if (program == null) {
    stderr.writeln('Analysis failed: ${workload.name}');
    return false;
  }
  for (var iteration = 0; iteration < iterations; iteration++) {
    for (final observed in [false, true]) {
      final result = observed
          ? measureObserved(program, workload.expectedOutput, inputs: inputs)
          : measureUnobserved(program, workload.expectedOutput, inputs: inputs);
      if (result is! RunSample) {
        stderr.writeln('Execution failed: ${workload.name}: $result');
        return false;
      }
      print(
        jsonEncode({
          'workload': workload.name,
          'family': workload.family,
          'iteration': iteration,
          'observed': observed,
          'steps': result.steps,
          'wallMicroseconds': result.elapsedMicroseconds,
          'events': result.events,
          'operations': workload.operations,
        }),
      );
    }
  }
  return true;
}
