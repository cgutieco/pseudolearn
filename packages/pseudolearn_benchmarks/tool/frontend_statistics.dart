import 'change_points.dart';
import 'statistics.dart';

Map<String, Object> summarizeFrontend(List<Map<String, dynamic>> records) {
  final groups = <String, List<Map<String, dynamic>>>{};
  for (final record in records) {
    (groups[record['workload'] as String] ??= []).add(record);
  }
  if (groups.length != 28) throw StateError('Expected 28 workloads');
  return {
    for (final entry in groups.entries)
      entry.key: summarizeFrontendGroup(entry.value),
  };
}

Map<String, Object> summarizeFrontendGroup(List<Map<String, dynamic>> records) {
  final processes = <int, Map<int, double>>{};
  final lines = records.first['lines'] as int;
  for (final record in records) {
    final duration = (record['nanoseconds'] as num).toDouble();
    final process = record['process'] as int;
    final iteration = record['iteration'] as int;
    final samples = processes[process] ??= {};
    if (duration <= 0 ||
        !duration.isFinite ||
        lines <= 0 ||
        record['lines'] != lines ||
        iteration < 0 ||
        iteration >= 30 ||
        process < 0 ||
        process >= 10 ||
        samples.containsKey(iteration)) {
      throw StateError('Invalid frontend sample');
    }
    samples[iteration] = duration;
  }
  if (processes.length != 10 ||
      processes.values.any((samples) => samples.length != 30)) {
    throw StateError('Incomplete frontend measurement');
  }
  final ordered = {
    for (final entry in processes.entries)
      entry.key: List.generate(30, (iteration) => entry.value[iteration]!),
  };
  return frontendMetrics(records.first, ordered);
}

Map<String, Object> frontendMetrics(
  Map<String, dynamic> first,
  Map<int, List<double>> processes,
) {
  final averages = processes.values.map(mean).toList();
  final interval = confidenceInterval(averages);
  final samples = processes.values.expand((samples) => samples).toList()
    ..sort();
  final lines = first['lines'] as int;
  final throughput = lines * 1e9 / mean(averages);
  final p95 = samples[284] / 1e6;
  return {
    'processes': processes.length,
    'samples': samples.length,
    'meanNanoseconds': mean(averages),
    'confidence95Nanoseconds': interval,
    'linesPerSecond': throughput,
    'confidence95LinesPerSecond': interval.reversed
        .map((duration) => lines * 1e9 / duration)
        .toList(),
    'p95Milliseconds': p95,
    'throughputPass': throughput >= 1000000,
    'latencyPass': lines != 10000 || p95 <= 16,
    'incomplete': first['incomplete'] as bool,
    'corpus': first['corpus'] as bool,
    'changePointCandidatesByProcess': {
      for (final entry in processes.entries)
        '${entry.key}': detectChangePoints(entry.value),
    },
    'stationarity': 'not_proven',
    'samplesDiscarded': 0,
  };
}
