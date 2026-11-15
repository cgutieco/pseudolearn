import 'dart:io';

import 'process_metrics.dart';

Future<Map<String, Object?>> observeBridgeProcess(Process child) async {
  var running = true;
  var samples = 0;
  var peakRss = 0;
  num? cpu;
  final completion = child.exitCode.then((status) {
    running = false;
    return status;
  });
  while (running) {
    final sample = await sampleProcess(child.pid);
    if (sample != null) {
      samples++;
      final rss = sample['rssBytes']!.toInt();
      if (rss > peakRss) peakRss = rss;
      cpu = sample['cpuSeconds'];
    }
    if (running) await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return {
    'exit_code': await completion,
    'metric_samples': samples,
    'peak_rss_sampled_bytes': samples == 0 ? null : peakRss,
    'peak_rss_is_lower_bound': true,
    'last_cpu_seconds': cpu,
  };
}
