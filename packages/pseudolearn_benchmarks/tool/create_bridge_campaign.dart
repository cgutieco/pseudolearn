import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';

import 'bridge_scenarios.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln('Usage: create_bridge_campaign.dart <new-campaign.json>');
    exitCode = 1;
    return;
  }
  try {
    final output = File(arguments.single);
    if (output.existsSync()) {
      throw const FormatException('Campaign already exists');
    }
    final exported = File('../pseudolearn_spec/specifications/export.json')
        .readAsStringSync();
    final corpus = jsonDecode(exported) as Map<String, Object?>;
    final workloads = corpusWorkloads(exported);
    if (workloads == null) throw const FormatException('Missing AWFY corpus');
    final scenarios = <Map<String, Object?>>[
      ...minimalBridgeScenarios(),
      for (final (workload, inputs) in workloads)
        for (final size in [1, 16, 64, 256])
          executionScenario(
            id: '${workload.name}-$size',
            source: workload.source,
            expected: '${workload.expectedOutput}\n',
            inputs: inputs,
            batchSize: size,
            family: workload.family,
          ),
      ...additionalBridgeScenarios(corpus),
    ];
    await output.writeAsString(
      jsonEncode({
        'format': 'bridge-campaign/1',
        'platform': 'macos',
        'frame_measurements': null,
        'release_artifacts': [
          '../pseudolearn_engine/target/release/pseudolearn_bench_worker',
          '../../apps/pseudolearn_app/native/target/release/libpseudolearn_bridge.dylib',
        ],
        'cargo_default_features': true,
        'prepare': [
          {
            'directory': '../pseudolearn_engine',
            'command': [
              'cargo',
              'build',
              '--release',
              '-p',
              'pseudolearn_bench_worker',
            ],
          },
          {
            'directory': '../../apps/pseudolearn_app',
            'command': [
              'cargo',
              'build',
              '--release',
              '--locked',
              '--lib',
              '--manifest-path',
              'native/Cargo.toml',
            ],
          },
        ],
        'workers': [
          {
            'variant': 'direct',
            'directory': '../pseudolearn_engine',
            'command': ['target/release/pseudolearn_bench_worker', 'bridge'],
            'scenarios': scenarios,
          },
          {
            'variant': 'bridge',
            'directory': '../../apps/pseudolearn_app',
            'command': ['dart', 'run', 'tool/bridge_benchmark_worker.dart'],
            'scenarios': scenarios,
          },
          {
            'variant': 'app-model',
            'directory': '../../apps/pseudolearn_app',
            'command': ['dart', 'run', 'tool/bridge_benchmark_worker.dart'],
            'scenarios': [visibleModelScenario()],
          },
        ],
      }),
    );
  } on Object catch (error) {
    stderr.writeln('Cannot prepare bridge campaign: $error');
    exitCode = 1;
  }
}
