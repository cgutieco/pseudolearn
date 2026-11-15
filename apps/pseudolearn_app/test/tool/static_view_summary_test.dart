import 'package:flutter_test/flutter_test.dart';
import '../../tool/static_view_summary.dart';

void main() {
  test('summarizes ten complete independent processes', () {
    final summary = buildStaticSummary(_samples());
    final sizes = summary['sizes']! as List<Map<String, Object?>>;
    final first = sizes.first;
    final metrics = first['metrics']! as Map<String, Object?>;
    final sceneBuild = metrics['scene_build_ns']! as Map<String, Object?>;

    expect(summary['process_count'], 10);
    expect(summary['iterations_per_process_and_size'], 30);
    expect(first['type_count'], 1);
    expect(first['scene_frames_min'], 2);
    expect(first['scene_edges_min'], 1);
    expect(sceneBuild['sample_count'], 300);
    expect(sceneBuild['process_mean_ci95_ns'], hasLength(2));
  });

  test('rejects a sample with a missing bridge operation', () {
    final rows = _samples();
    rows.first['view_operations'] = 3;

    expect(() => buildStaticSummary(rows), throwsFormatException);
  });
}

List<Map<String, Object?>> _samples() => [
  for (var process = 0; process < 10; process++)
    for (var iteration = 0; iteration < 30; iteration++)
      for (final typeCount in [1, 10, 100])
        {
          'process_id': process + 1,
          'iteration': iteration,
          'type_count': typeCount,
          'source_bytes': typeCount * 100,
          'view_load_ns': 1000 + process * 100 + iteration,
          'scene_build_ns': 2000 + process * 100 + iteration,
          'layout_ns': 300 + process * 10 + iteration,
          'paint_record_ns': 400 + process * 10 + iteration,
          'view_operations': 4,
          'scene_operations': 4,
          'scene_frames': typeCount + 1,
          'scene_edges': typeCount,
          'rss_bytes': 100000 + process * 1000 + iteration,
        },
];
