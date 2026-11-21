import 'dart:io';

import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import 'bridge_benchmark_script.dart';

typedef BridgeMeasurementSink = void Function(Map<String, Object?> row);

int expectedIterations(Map<String, Object?> configuration) {
  final iterations = configuration['mode'] == 'smoke' ? 1 : 30;
  if (configuration['iterations'] != iterations) {
    throw const FormatException('Expected thirty iterations');
  }
  return iterations;
}

Future<void> runBridgeCampaign(
  Map<String, Object?> configuration,
  RustTransport Function() openTransport,
  BridgeMeasurementSink emit,
) async {
  final iterations = expectedIterations(configuration);
  final resolution = observedClockResolution();
  final scenarios = (configuration['scenarios'] as List<Object?>)
      .cast<Map<String, Object?>>();
  for (final scenario in scenarios) {
    for (var iteration = 0; iteration < iterations; iteration++) {
      final script = BridgeBenchmarkScript(openTransport());
      try {
        for (final row in await script.run(scenario)) {
          emit({
            ...row,
            'scenario': scenario['id'],
            'iteration': iteration,
            'verified': true,
            'rss_bytes': ProcessInfo.currentRss,
            'clock_resolution_observed_nanoseconds': resolution,
          });
        }
      } finally {
        await script.close();
      }
    }
  }
}

num? observedClockResolution() {
  final clock = Stopwatch()..start();
  var previous = clock.elapsedTicks;
  int? minimum;
  for (var sample = 0; sample < 1000; sample++) {
    final current = clock.elapsedTicks;
    final delta = current - previous;
    if (delta > 0 && (minimum == null || delta < minimum)) minimum = delta;
    previous = current;
  }
  return minimum == null ? null : minimum * 1000000000 / clock.frequency;
}
