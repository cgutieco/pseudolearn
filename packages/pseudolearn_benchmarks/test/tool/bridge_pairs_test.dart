import 'package:test/test.dart';

import '../../tool/bridge_pairs.dart';

List<Map<String, Object?>> _records() => [
  for (var process = 0; process < 10; process++)
    for (var iteration = 0; iteration < 30; iteration++)
      for (final variant in ['direct', 'bridge'])
        {
          'variant': variant,
          'scenario': 'source',
          'family': 'numeric',
          'operation': 'advance',
          'process': process,
          'iteration': iteration,
          'nanoseconds': variant == 'direct' ? 100 : 200,
        },
];

void main() {
  test(
    'pairs processes and reports deterministic geometric family intervals',
    () {
      final result = pairedBridgeRatios(_records());
      final ratio =
          (result['ratios']
                  as Map<String, Object>)['bridge/direct/numeric/advance']
              as Map<String, Object>;
      expect(ratio['geometricMeanRatio'], closeTo(2, 0.000001));
      final interval = ratio['confidence95'] as List<double>;
      expect(interval.first, closeTo(2, 0.000001));
      expect(interval.last, closeTo(2, 0.000001));
    },
  );

  test('rejects missing variants and preserves unquantifiable families', () {
    expect(
      () => pairedBridgeRatios(
        _records().where((row) => row['variant'] == 'direct').toList(),
      ),
      throwsFormatException,
    );
    final rows = _records();
    for (final row in rows.where((row) => row['variant'] == 'direct')) {
      row['nanoseconds'] = 0;
    }
    final result = pairedBridgeRatios(rows);
    expect(result['ratios'], isEmpty);
    expect(result['unquantifiable_families'], ['numeric/advance']);
    expect(rows, hasLength(600));
  });
}
