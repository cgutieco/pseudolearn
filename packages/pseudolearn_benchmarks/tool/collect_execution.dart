import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'measurement_environment.dart';
import 'collect_frontend.dart' show frontendEnvironment, save;
import 'statistics.dart';
import 'execution_statistics.dart';

Future<void> main() async {
  try {
    const output = 'results/macos-r5-vm';
    final provenance = await frontendEnvironment();
    await Directory(output).create(recursive: true);
    await save(output, 'capture', provenance);
    await checked('cargo', [
      'build',
      '--release',
      '--manifest-path',
      '../pseudolearn_engine/Cargo.toml',
      '-p',
      'pseudolearn_bench_worker',
    ]);
    final records = <Map<String, dynamic>>[];
    final processes = <Map<String, Object>>[];
    for (var invocation = 0; invocation < 10; invocation++) {
      stdout.writeln('Execution: process ${invocation + 1}/10');
      processes.add(
        await collectProcess(
          'native',
          invocation,
          records,
          worker: '../../pseudolearn_engine/target/release/pseudolearn_bench_worker',
          workerArguments: ['execute'],
          expectedRows: 300,
        ),
      );
      await save(output, 'raw', records);
      await save(output, 'processes', processes);
    }
    final baseline = jsonDecode(
      await File('results/macos-r3-awfy/summary.json').readAsString(),
    ) as Map<String, dynamic>;
    final measurements = summarizeExecution(records);
    final ratios = executionRatios(measurements, baseline);
    await save(output, 'summary', {
      'environment': provenance,
      'measurements': measurements,
      ...ratios,
      'limitations': [
        'Shared hardware; all samples retained; reference is the approved historical baseline',
      ],
    });
    if (ratios['minimumPassed'] != true) exitCode = 1;
  } on Object catch (error) {
    stderr.writeln('Execution collection failed: $error');
    exitCode = 1;
  }
}

Map<String, Object> executionRatios(
  Map<String, Object> measurements,
  Map<String, dynamic> baseline,
) {
  final ratios = <String, double>{};
  for (final entry in measurements.entries) {
    final measurement = entry.value as Map<String, Object>;
    final original =
        baseline['measurements'][entry.key] as Map<String, dynamic>;
    ratios[entry.key] =
        (original['meanWallMicroseconds'] as num) /
        (measurement['meanWallMicroseconds'] as num);
  }
  final geometric = exp(mean(ratios.values.map(log).toList()));
  final minimum = ratios.values.reduce(min);
  return {
    'ratios': ratios,
    'geometricMean': geometric,
    'minimum': minimum,
    'minimumPassed': geometric >= 10 && minimum >= 5,
    'targetReached': geometric >= 30,
  };
}
