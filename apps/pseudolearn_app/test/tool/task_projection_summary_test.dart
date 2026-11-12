import 'package:flutter_test/flutter_test.dart';
import '../../tool/task_projection_summary.dart';

void main() {
  test('summarizes ten complete processes with provenance', () {
    final summary = buildTaskProjectionSummary(_samples(), _manifest());
    final loads = summary['loads']! as List<Map<String, Object?>>;
    final metrics = loads.first['metrics']! as Map<String, Object?>;
    final pure = metrics['pure_projection_ns']! as Map<String, Object?>;

    expect(summary['process_count'], 10);
    expect(loads, hasLength(2));
    expect(pure['sample_count'], 300);
    expect(pure['p95_ns'], greaterThanOrEqualTo(pure['p50_ns']! as int));
    expect(pure['process_mean_ci95_ns'], hasLength(2));
  });

  test('rejects a missing manifest and an incomplete provenance', () {
    expect(() => buildTaskProjectionSummary(_samples(), null), throwsFormatException);
    final incomplete = _manifest()..remove('head');
    expect(
      () => buildTaskProjectionSummary(_samples(), incomplete),
      throwsFormatException,
    );
  });

  test('rejects scenes that are not run on the real host', () {
    for (final scene in [
      {'id': 'identities', 'source_sha256': 'a', 'host': 'simulated'},
      {'id': 'identities', 'source_sha256': 'a', 'host': 'real', 'simulatedScenario': 'x'},
      {'id': 'identities', 'source_sha256': 'a'},
      {'id': 'identities', 'host': 'real'},
    ]) {
      final manifest = _manifest()..['scenes'] = [scene];
      expect(
        () => buildTaskProjectionSummary(_samples(), manifest),
        throwsFormatException,
      );
    }
  });

  test('rejects a manifest without scenes or with an empty list', () {
    expect(
      () => buildTaskProjectionSummary(_samples(), _manifest()..remove('scenes')),
      throwsFormatException,
    );
    expect(
      () => buildTaskProjectionSummary(_samples(), _manifest()..['scenes'] = []),
      throwsFormatException,
    );
  });

  test('rejects an incomplete sample', () {
    final rows = _samples()..removeLast();
    expect(() => buildTaskProjectionSummary(rows, _manifest()), throwsFormatException);
  });

  test('rejects fewer independent processes', () {
    final rows = _samples().where((row) => row['process_id'] != 1).toList();
    expect(() => buildTaskProjectionSummary(rows, _manifest()), throwsFormatException);
  });

  test('rejects a divergent result inside one load', () {
    final rows = _samples();
    rows.first['visible_tasks'] = 99;
    expect(() => buildTaskProjectionSummary(rows, _manifest()), throwsFormatException);
  });

  test('rejects a different clock configuration', () {
    final rows = _samples();
    rows.last['clock_resolution_ticks'] = 7;
    expect(() => buildTaskProjectionSummary(rows, _manifest()), throwsFormatException);
  });

  test('rejects an invalid or unmeasured timing', () {
    final rows = _samples();
    rows.first['integrated_ns'] = 0;
    expect(() => buildTaskProjectionSummary(rows, _manifest()), throwsFormatException);
  });
}

Map<String, Object?> _manifest() => {
  'head': 'abc',
  'working_tree_diff_sha256': 'd',
  'harness_sources_sha256': 'h',
  'fixtures_sha256': 'f',
  'flutter': '3.50.0',
  'dart': '3.13.4',
  'build_mode': 'test',
  'operating_system': 'macOS',
  'hardware': 'Mac',
  'seed': 'fixed',
  'loads': 'x',
  'candidate_threshold': 50,
  'scenes': [
    {'id': 'identities', 'source_sha256': 'a', 'host': 'real'},
  ],
};

List<Map<String, Object?>> _samples() => [
  for (var process = 0; process < 10; process++)
    for (var iteration = 0; iteration < 30; iteration++)
      for (final tasks in [1, 100])
        {
          'process_id': process + 1,
          'iteration': iteration,
          'task_count': tasks,
          'window_events': 100,
          'retained_events': tasks * 11 + 100,
          'visible_events': 100,
          'visible_tasks': tasks,
          'flow_markers': 100,
          'flow_connectors': tasks,
          'clock_resolution_ticks': 41,
          'pure_projection_ns': 1000 + process * 10 + iteration,
          'integrated_ns': 5000 + process * 10 + iteration,
          'rss_bytes': 100000 + iteration,
        },
];
