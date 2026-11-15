import 'dart:math';

import 'change_points.dart';

Map<String, Object?> summarizeBridge(List<Map<String, Object?>> records) {
  final groups = <String, List<Map<String, Object?>>>{};
  for (final record in records) {
    final key =
        '${record['variant']}/${record['scenario']}/${record['operation']}';
    groups.putIfAbsent(key, () => []).add(record);
  }
  if (groups.isEmpty) throw const FormatException('No bridge samples');
  return {for (final entry in groups.entries) entry.key: _summary(entry.value)};
}

Map<String, Object?> _summary(List<Map<String, Object?>> records) {
  final processes = <int, Map<int, List<double>>>{};
  for (final record in records) {
    final process = record['process'] as int;
    final iteration = record['iteration'] as int;
    final duration = (record['nanoseconds'] as num).toDouble();
    if (duration < 0 || !duration.isFinite) {
      throw const FormatException('Invalid bridge latency');
    }
    processes
        .putIfAbsent(process, () => {})
        .putIfAbsent(iteration, () => [])
        .add(duration);
  }
  if (processes.length != 10 ||
      processes.values.any((rounds) => rounds.length != 30)) {
    throw const FormatException(
      'Bridge campaign requires ten processes and thirty iterations',
    );
  }
  final durations =
      records
          .map((record) => (record['nanoseconds'] as num).toDouble())
          .toList()
        ..sort();
  final medians = [
    for (final rounds in processes.values)
      _mean([for (final values in rounds.values) _mean(values)]),
  ];
  final median = _quantile(durations, 0.5);
  final deviations = durations.map((value) => (value - median).abs()).toList()
    ..sort();
  return {
    'requests': durations.length,
    'processes': processes.length,
    'p50_nanoseconds': median,
    'p95_nanoseconds': _quantile(durations, 0.95),
    'mad_nanoseconds': _quantile(deviations, 0.5),
    'iqr_nanoseconds': _quantile(durations, 0.75) - _quantile(durations, 0.25),
    'mean_process_latency_ci95_nanoseconds': _confidence(medians),
    'process_mean_change_candidates': detectChangePoints(medians),
    'iteration_mean_change_candidates_by_process': {
      for (final entry in processes.entries)
        '${entry.key}': detectChangePoints(
          List.generate(30, (iteration) => _mean(entry.value[iteration]!)),
        ),
    },
    'stationarity_demonstrated': false,
  };
}

double _mean(List<double> values) =>
    values.reduce((left, right) => left + right) / values.length;

double _quantile(List<double> sorted, double fraction) =>
    sorted[(fraction * (sorted.length - 1)).round()];

List<double> _confidence(List<double> processes) {
  final random = Random(42);
  final samples = [
    for (var sample = 0; sample < 2000; sample++)
      _mean([
        for (var process = 0; process < processes.length; process++)
          processes[random.nextInt(processes.length)],
      ]),
  ]..sort();
  return [_quantile(samples, 0.025), _quantile(samples, 0.975)];
}
