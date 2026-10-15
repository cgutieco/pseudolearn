import 'package:test/test.dart';

import '../../tool/frontend_statistics.dart';

List<Map<String, dynamic>> samples() => [
  for (var process = 0; process < 10; process++)
    for (var iteration = 0; iteration < 30; iteration++)
      {
        'process': process,
        'iteration': iteration,
        'nanoseconds': 1000000,
        'lines': 10000,
        'incomplete': false,
        'corpus': false,
      },
];

void main() {
  test('computes throughput and latency from independent process means', () {
    final summary = summarizeFrontendGroup(samples());
    expect(summary['linesPerSecond'], 10000000);
    expect(summary['p95Milliseconds'], 1);
    expect(summary['confidence95Nanoseconds'], [1000000, 1000000]);
    expect(summary['samplesDiscarded'], 0);
  });
  test('rejects incomplete or duplicate samples', () {
    expect(
      () => summarizeFrontendGroup(samples()..removeLast()),
      throwsStateError,
    );
    final duplicate = samples()..last['iteration'] = 0;
    expect(() => summarizeFrontendGroup(duplicate), throwsStateError);
  });
  test('rejects nonpositive durations and mismatched line counts', () {
    expect(
      () => summarizeFrontendGroup(samples()..first['nanoseconds'] = 0),
      throwsStateError,
    );
    expect(
      () => summarizeFrontendGroup(samples()..last['lines'] = 1),
      throwsStateError,
    );
  });
  test('reports failed thresholds without discarding slow samples', () {
    final slow = samples();
    for (final record in slow) {
      record['nanoseconds'] = 20000000;
    }
    final summary = summarizeFrontendGroup(slow);
    expect(summary['throughputPass'], false);
    expect(summary['latencyPass'], false);
    expect(summary['samples'], 300);
  });
}
