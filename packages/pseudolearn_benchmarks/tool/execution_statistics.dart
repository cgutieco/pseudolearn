import 'change_points.dart';
import 'statistics.dart';

Map<String, Object> summarizeExecution(List<Map<String, dynamic>> records) {
  final groups = <String, List<Map<String, dynamic>>>{};
  for (final record in records) {
    final key = '${record['target']}/${record['workload']}/false';
    (groups[key] ??= []).add(record);
  }
  if (groups.length != 10) throw StateError('Expected ten workloads');
  return {
    for (final entry in groups.entries)
      entry.key: summarizeExecutionGroup(entry.value),
  };
}

Map<String, Object> summarizeExecutionGroup(
  List<Map<String, dynamic>> records,
) {
  final processes = <int, Map<int, double>>{};
  for (final record in records) {
    final process = record['process'] as int;
    final iteration = record['iteration'] as int;
    final duration = (record['nanoseconds'] as num).toDouble();
    final samples = processes[process] ??= {};
    if (process < 0 ||
        process >= 10 ||
        iteration < 0 ||
        iteration >= 30 ||
        duration <= 0 ||
        !duration.isFinite ||
        samples.containsKey(iteration)) {
      throw StateError('Invalid execution sample');
    }
    samples[iteration] = duration / 1000;
  }
  if (processes.length != 10 ||
      processes.values.any((samples) => samples.length != 30)) {
    throw StateError('Incomplete execution measurement');
  }
  final ordered = {
    for (final entry in processes.entries)
      '${entry.key}': List.generate(30, (iteration) => entry.value[iteration]!),
  };
  final averages = ordered.values.map(mean).toList();
  return {
    'processes': processes.length,
    'samples': records.length,
    'meanWallMicroseconds': mean(averages),
    'confidence95': confidenceInterval(averages),
    'changePointCandidatesByProcess': {
      for (final entry in ordered.entries)
        entry.key: detectChangePoints(entry.value),
    },
    'samplesDiscarded': 0,
    'stationarity': 'not_proven',
  };
}
