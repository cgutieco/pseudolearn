import 'dart:math';

import 'change_points.dart';

List<double> confidenceInterval(List<double> samples) {
  if (samples.isEmpty) return const [];
  final random = Random(42);
  final estimates = List.generate(1000, (_) {
    final selected = List.generate(
      samples.length,
      (_) => samples[random.nextInt(samples.length)],
    );
    return mean(selected);
  })..sort();
  return [estimates[25], estimates[974]];
}

double mean(List<double> samples) =>
    samples.reduce((first, second) => first + second) / samples.length;

Map<String, Object> summarize(List<Map<String, dynamic>> records) {
  final groups = <String, List<Map<String, dynamic>>>{};
  for (final record in records) {
    final key =
        '${record['target']}/${record['workload']}/${record['observed']}';
    (groups[key] ??= []).add(record);
  }
  final summary = <String, Object>{};
  for (final entry in groups.entries) {
    summary[entry.key] = summarizeGroup(entry.value);
  }
  return summary;
}

Map<String, Object> summarizeGroup(List<Map<String, dynamic>> records) {
  final processes = <int, List<double>>{};
  for (final record in records) {
    final process = record['process'] as int;
    (processes[process] ??= []).add(
      (record['wallMicroseconds'] as num).toDouble(),
    );
  }
  final averages = processes.values.map(mean).toList();
  final changes = {
    for (final entry in processes.entries)
      '${entry.key}': detectChangePoints(entry.value),
  };
  final drift = changes.values.any((boundaries) => boundaries.isNotEmpty);
  final steps = (records.first['steps'] as num).toDouble();
  final operations = (records.first['operations'] as num).toDouble();
  return {
    'processes': averages.length,
    'samples': records.length,
    'meanWallMicroseconds': mean(averages),
    'confidence95': confidenceInterval(averages),
    'nanosecondsPerStep': mean(averages) * 1000 / steps,
    'microsecondsPerOperation': mean(averages) / operations,
    'stationarity': drift ? 'change_points_detected' : 'not_proven',
    'changePointCandidatesByProcess': changes,
    'samplesDiscarded': 0,
  };
}

Map<String, Object> observationRatios(List<Map<String, dynamic>> records) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final record in records) {
    final key = '${record['target']}/${record['family']}/${record['process']}';
    (grouped[key] ??= []).add(record);
  }
  final ratios = <String, List<double>>{};
  for (final entry in grouped.entries) {
    final workloads = <String, Map<bool, List<double>>>{};
    for (final record in entry.value) {
      final modes = workloads[record['workload'] as String] ??= {};
      (modes[record['observed'] as bool] ??= []).add(
        (record['wallMicroseconds'] as num).toDouble(),
      );
    }
    final values = workloads.values
        .map((modes) => mean(modes[true]!) / mean(modes[false]!))
        .toList();
    final ratio = exp(mean(values.map(log).toList()));
    final family = entry.key.substring(0, entry.key.lastIndexOf('/'));
    (ratios[family] ??= []).add(ratio);
  }
  return {
    for (final entry in ratios.entries)
      entry.key: {
        'geometricMeanRatio': exp(mean(entry.value.map(log).toList())),
        'confidence95': confidenceInterval(entry.value.map(log).toList())
            .map(exp)
            .toList(),
      },
  };
}
