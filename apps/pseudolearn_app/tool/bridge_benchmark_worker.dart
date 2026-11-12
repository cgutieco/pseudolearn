import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

import 'bridge_benchmark_script.dart';

Future<void> main() async {
  try {
    await initializeNativeBridge();
    final configuration =
        jsonDecode(await stdin.transform(utf8.decoder).join())
            as Map<String, Object?>;
    final iterations = configuration['mode'] == 'smoke' ? 1 : 30;
    if (configuration['iterations'] != iterations) {
      throw const FormatException('Expected thirty iterations');
    }
    final resolution = _clockResolution();
    final scenarios = (configuration['scenarios'] as List<Object?>)
        .cast<Map<String, Object?>>();
    for (final scenario in scenarios) {
      for (var iteration = 0; iteration < iterations; iteration++) {
        final script = BridgeBenchmarkScript(openNativeTransport());
        try {
          final rows = await script.run(scenario);
          for (final row in rows) {
            stdout.writeln(
              jsonEncode({
                ...row,
                'scenario': scenario['id'],
                'iteration': iteration,
                'verified': true,
                'rss_bytes': ProcessInfo.currentRss,
                'clock_resolution_observed_nanoseconds': resolution,
              }),
            );
          }
        } finally {
          await script.close();
        }
      }
    }
  } on Object catch (error) {
    stderr.writeln('Bridge worker failed: $error');
    exitCode = 1;
  }
}

num? _clockResolution() {
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
