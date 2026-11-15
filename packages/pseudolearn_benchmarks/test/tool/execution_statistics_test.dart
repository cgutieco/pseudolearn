import 'package:test/test.dart';

import '../../tool/execution_statistics.dart';

List<Map<String, dynamic>> samples() => [
  for (var process = 0; process < 10; process++)
    for (var iteration = 0; iteration < 30; iteration++)
      {'process': process, 'iteration': iteration, 'nanoseconds': 2000},
];

void main() {
  test('summarizes independent processes without discarding samples', () {
    final result = summarizeExecutionGroup(samples());
    expect(result['processes'], 10);
    expect(result['samples'], 300);
    expect(result['meanWallMicroseconds'], 2.0);
    expect(result['samplesDiscarded'], 0);
  });

  test('rejects missing and duplicated measurements', () {
    final incomplete = samples()..removeLast();
    expect(() => summarizeExecutionGroup(incomplete), throwsStateError);
    final duplicate = samples()..add(samples().first);
    expect(() => summarizeExecutionGroup(duplicate), throwsStateError);
    expect(() => summarizeExecution([]), throwsStateError);
  });

  test('rejects nonpositive and nonfinite durations', () {
    for (final duration in [0, -1, double.nan, double.infinity]) {
      final invalid = samples();
      invalid.first['nanoseconds'] = duration;
      expect(() => summarizeExecutionGroup(invalid), throwsStateError);
    }
  });
}
