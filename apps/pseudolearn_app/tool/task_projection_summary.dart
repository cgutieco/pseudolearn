import 'dart:convert';
import 'dart:io';
import 'dart:math';

const int expectedProcesses = 10;
const int expectedIterations = 30;
const List<String> metricNames = ['pure_projection_ns', 'integrated_ns'];
const List<String> requiredProvenance = [
  'head',
  'working_tree_diff_sha256',
  'harness_sources_sha256',
  'fixtures_sha256',
  'flutter',
  'dart',
  'build_mode',
  'operating_system',
  'hardware',
  'seed',
  'loads',
  'candidate_threshold',
];

Future<void> main(List<String> arguments) async {
  if (arguments.length < 5 ||
      arguments[0] != '--manifest' ||
      arguments[2] != '--output') {
    stderr.writeln(
      'Usage: dart run tool/task_projection_summary.dart --manifest FILE '
      '--output FILE INPUT...',
    );
    exitCode = 64;
    return;
  }
  final manifest = jsonDecode(await File(arguments[1]).readAsString());
  final rows = await _readRows(arguments.skip(4).map(File.new).toList());
  final summary = buildTaskProjectionSummary(
    rows,
    manifest is Map<String, Object?> ? manifest : null,
  );
  final output = File(arguments[3]);
  await output.parent.create(recursive: true);
  await output.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(summary)}\n',
  );
}

Future<List<Map<String, Object?>>> _readRows(List<File> inputs) async {
  final rows = <Map<String, Object?>>[];
  for (final input in inputs) {
    for (final line in await input.readAsLines()) {
      if (line.trim().isEmpty) continue;
      final decoded = jsonDecode(line);
      if (decoded is! Map<String, Object?>) {
        throw FormatException('Sample row must be an object: ${input.path}');
      }
      rows.add(decoded);
    }
  }
  return rows;
}

Map<String, Object?> buildTaskProjectionSummary(
  List<Map<String, Object?>> rows,
  Map<String, Object?>? manifest,
) {
  _requireManifest(manifest);
  if (rows.isEmpty) throw const FormatException('No measurement samples.');
  final samples = rows.map(TaskProjectionSample.fromJson).toList();
  final processIds = samples.map((sample) => sample.processId).toSet();
  if (processIds.length != expectedProcesses) {
    throw FormatException(
      'Expected $expectedProcesses processes; found ${processIds.length}.',
    );
  }
  _requireSingleConfiguration(samples);
  final keys = samples.map((sample) => sample.loadKey).toSet().toList()
    ..sort();
  return {
    'process_count': processIds.length,
    'iterations_per_process_and_load': expectedIterations,
    'bootstrap_seed': 20261102,
    'bootstrap_resamples': 10000,
    'percentile_estimator': 'nearest-rank',
    'candidate_threshold_ms': manifest!['candidate_threshold'],
    'loads': [for (final key in keys) _loadSummary(samples, key, processIds)],
  };
}

void _requireManifest(Map<String, Object?>? manifest) {
  if (manifest == null) throw const FormatException('Missing manifest.');
  for (final field in requiredProvenance) {
    final value = manifest[field];
    if (value == null || value.toString().isEmpty) {
      throw FormatException('Manifest lacks provenance field $field.');
    }
  }
}

void _requireSingleConfiguration(List<TaskProjectionSample> samples) {
  final first = samples.first;
  for (final sample in samples) {
    if (sample.ticksPerSecondClass != first.ticksPerSecondClass) {
      throw const FormatException('Samples disagree on the clock class.');
    }
  }
}

Map<String, Object?> _loadSummary(
  List<TaskProjectionSample> samples,
  String key,
  Set<int> processIds,
) {
  final load = samples.where((sample) => sample.loadKey == key).toList();
  final expected = expectedProcesses * expectedIterations;
  if (load.length != expected) {
    throw FormatException(
      'Load $key must have $expected samples; found ${load.length}.',
    );
  }
  final processes = {
    for (final id in processIds)
      id: load.where((sample) => sample.processId == id).toList(),
  };
  for (final entry in processes.entries) {
    final iterations = entry.value.map((sample) => sample.iteration).toSet();
    if (iterations.length != expectedIterations ||
        entry.value.length != expectedIterations) {
      throw FormatException('Process ${entry.key} is incomplete for $key.');
    }
  }
  final first = load.first;
  for (final sample in load) {
    if (!sample.sameResultAs(first)) {
      throw FormatException('Samples of $key disagree on their result.');
    }
  }
  return {
    'task_count': first.taskCount,
    'window_events': first.windowEvents,
    'retained_events': first.retainedEvents,
    'visible_events': first.visibleEvents,
    'visible_tasks': first.visibleTasks,
    'flow_markers': first.flowMarkers,
    'flow_connectors': first.flowConnectors,
    'rss_peak_sampled_bytes': load.map((sample) => sample.rssBytes).reduce(max),
    'metrics': {
      for (final metric in metricNames)
        metric: _metricSummary([
          for (final rows in processes.values)
            [for (final row in rows) row.metric(metric)],
        ]),
    },
  };
}

Map<String, Object?> _metricSummary(List<List<int>> byProcess) {
  final samples = byProcess.expand((values) => values).toList()..sort();
  final means = [
    for (final values in byProcess)
      values.reduce((left, right) => left + right) / values.length,
  ];
  return {
    'sample_count': samples.length,
    'minimum_ns': samples.first,
    'p50_ns': _nearestRank(samples, 0.5),
    'p95_ns': _nearestRank(samples, 0.95),
    'maximum_ns': samples.last,
    'mean_of_process_means_ns': means.reduce((a, b) => a + b) / means.length,
    'process_mean_ci95_ns': _bootstrap(means),
  };
}

int _nearestRank(List<int> sorted, double percentile) =>
    sorted[(sorted.length * percentile).ceil() - 1];

List<double> _bootstrap(List<double> means) {
  final random = Random(20261102);
  final resampled = <double>[];
  for (var round = 0; round < 10000; round++) {
    var total = 0.0;
    for (var index = 0; index < means.length; index++) {
      total += means[random.nextInt(means.length)];
    }
    resampled.add(total / means.length);
  }
  resampled.sort();
  return [resampled[250], resampled[9749]];
}

final class TaskProjectionSample {
  final int processId;
  final int iteration;
  final int taskCount;
  final int windowEvents;
  final int retainedEvents;
  final int visibleEvents;
  final int visibleTasks;
  final int flowMarkers;
  final int flowConnectors;
  final int pureProjectionNs;
  final int integratedNs;
  final int rssBytes;
  final int ticksPerSecondClass;

  const TaskProjectionSample._({
    required this.processId,
    required this.iteration,
    required this.taskCount,
    required this.windowEvents,
    required this.retainedEvents,
    required this.visibleEvents,
    required this.visibleTasks,
    required this.flowMarkers,
    required this.flowConnectors,
    required this.pureProjectionNs,
    required this.integratedNs,
    required this.rssBytes,
    required this.ticksPerSecondClass,
  });

  factory TaskProjectionSample.fromJson(Map<String, Object?> json) {
    final sample = TaskProjectionSample._(
      processId: _integer(json, 'process_id'),
      iteration: _integer(json, 'iteration'),
      taskCount: _integer(json, 'task_count'),
      windowEvents: _integer(json, 'window_events'),
      retainedEvents: _integer(json, 'retained_events'),
      visibleEvents: _integer(json, 'visible_events'),
      visibleTasks: _integer(json, 'visible_tasks'),
      flowMarkers: _integer(json, 'flow_markers'),
      flowConnectors: _integer(json, 'flow_connectors'),
      pureProjectionNs: _integer(json, 'pure_projection_ns'),
      integratedNs: _integer(json, 'integrated_ns'),
      rssBytes: _integer(json, 'rss_bytes'),
      ticksPerSecondClass: _integer(json, 'clock_resolution_ticks'),
    );
    if (sample.iteration < 0 ||
        sample.iteration >= expectedIterations ||
        sample.pureProjectionNs <= 0 ||
        sample.integratedNs <= 0 ||
        sample.rssBytes <= 0 ||
        sample.visibleEvents != sample.flowMarkers ||
        sample.visibleEvents > sample.windowEvents ||
        sample.visibleEvents > sample.retainedEvents) {
      throw FormatException('Invalid dynamic measurement sample: $json');
    }
    return sample;
  }

  String get loadKey => '${taskCount.toString().padLeft(4, '0')}x$windowEvents';

  bool sameResultAs(TaskProjectionSample other) =>
      retainedEvents == other.retainedEvents &&
      visibleEvents == other.visibleEvents &&
      visibleTasks == other.visibleTasks &&
      flowMarkers == other.flowMarkers &&
      flowConnectors == other.flowConnectors;

  int metric(String name) => switch (name) {
    'pure_projection_ns' => pureProjectionNs,
    'integrated_ns' => integratedNs,
    _ => throw ArgumentError.value(name, 'name'),
  };
}

int _integer(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is int) return value;
  throw FormatException('Sample field $field must be an integer.');
}
