import 'package:test/test.dart';

import '../../tool/bridge_statistics.dart';
import '../../tool/collect_bridge.dart';

List<Map<String, Object?>> _records() => [
  for (var process = 0; process < 10; process++)
    for (var iteration = 0; iteration < 30; iteration++)
      {
        'variant': 'fixture',
        'scenario': 'example',
        'operation': 'advance',
        'process': process,
        'iteration': iteration,
        'nanoseconds': 100,
        'request': 0,
        'verified': true,
      },
];

void main() {
  test(
    'summarizes independent processes with deterministic confidence intervals',
    () {
      final summary = summarizeBridge(_records());
      final group = summary['fixture/example/advance'] as Map<String, Object?>;
      expect(group['p95_nanoseconds'], 100);
      expect(group['mean_process_latency_ci95_nanoseconds'], [100, 100]);
      expect(group['stationarity_demonstrated'], false);
    },
  );

  test('rejects incomplete processes and invalid latencies', () {
    expect(
      () => summarizeBridge(_records()..removeLast()),
      throwsFormatException,
    );
    final records = _records();
    records.first['nanoseconds'] = double.nan;
    expect(() => summarizeBridge(records), throwsFormatException);
    expect(() => summarizeBridge([]), throwsFormatException);
  });

  test(
    'rejects duplicate requests and unverified or incomplete worker output',
    () {
      final rows = _records().where((row) => row['process'] == 0).toList();
      validateBridgeRows(rows, {
        'example': ['advance'],
      });
      expect(
        () => validateBridgeRows(
          [...rows, rows.first],
          {
            'example': ['advance'],
          },
        ),
        throwsFormatException,
      );
      expect(
        () => validateBridgeRows(rows.sublist(1), {
          'example': ['advance'],
        }),
        throwsFormatException,
      );
      expect(
        () => validateBridgeRows(rows, {
          'example': ['advance', 'query_frame'],
        }),
        throwsFormatException,
      );
      rows.first['verified'] = false;
      expect(
        () => validateBridgeRows(rows, {
          'example': ['advance'],
        }),
        throwsFormatException,
      );
    },
  );
}
