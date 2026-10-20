import 'statistics.dart';

Map<String, Object?> pairedBridgeRatios(List<Map<String, Object?>> records) {
  final groups = <String, Map<String, List<Map<String, Object?>>>>{};
  for (final row in records) {
    if (!{'direct', 'bridge'}.contains(row['variant'])) continue;
    final key = '${row['scenario']}/${row['operation']}/${row['process']}';
    groups
        .putIfAbsent(key, () => {})
        .putIfAbsent(row['variant'] as String, () => [])
        .add(row);
  }
  final unquantifiable = <String>{};
  for (final pair in groups.values) {
    if (pair.length != 2) {
      throw const FormatException('Unpaired bridge measurement');
    }
    if (pair.values.any(
      (rows) =>
          rows.fold<num>(0, (sum, row) => sum + (row['nanoseconds'] as num)) <=
          0,
    )) {
      unquantifiable.add(_family(pair.values.first.first));
    }
  }
  final paired = <Map<String, dynamic>>[
    for (final pair in groups.values)
      for (final rows in pair.values)
        for (final row in rows)
          if (!unquantifiable.contains(_family(row)))
            {
              'target': 'bridge/direct',
              'family': _family(row),
              'workload': row['scenario'],
              'process': row['process'],
              'observed': row['variant'] == 'bridge',
              'wallMicroseconds': (row['nanoseconds'] as num) / 1000,
            },
  ];
  return {
    'ratios': observationRatios(paired),
    'unquantifiable_families': unquantifiable.toList(),
    'reason': unquantifiable.isEmpty
        ? null
        : 'Nonpositive process mean; raw samples retained',
  };
}

String _family(Map<String, Object?> row) =>
    '${row['family'] ?? 'behavior'}/${row['operation']}';
