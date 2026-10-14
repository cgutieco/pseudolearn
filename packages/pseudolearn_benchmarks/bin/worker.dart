import 'dart:convert';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';

void main() {
  for (final workload in [...annexWorkloads, ...awfyWorkloads]) {
    if (!runWorkload(workload)) return;
  }
}

bool runWorkload(Workload workload) {
  final program = analyze(workload.source);
  if (program == null) {
    print(jsonEncode({'error': 'analysis', 'workload': workload.name}));
    return false;
  }
  for (var iteration = 0; iteration < 30; iteration++) {
    final samples = [
      measureUnobserved(program, workload.expectedOutput),
      measureObserved(program, workload.expectedOutput),
    ];
    for (final (mode, result) in samples.indexed) {
      if (result is! RunSample) {
        print(jsonEncode({'error': 'execution', 'workload': workload.name}));
        return false;
      }
      print(
        jsonEncode({
          'workload': workload.name,
          'family': workload.family,
          'iteration': iteration,
          'observed': mode == 1,
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
