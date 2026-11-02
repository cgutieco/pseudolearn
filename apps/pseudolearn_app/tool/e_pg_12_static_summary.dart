import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> arguments) async {
  if (arguments.length < 3 || arguments[0] != '--output') {
    stderr.writeln(
      'Usage: dart run tool/e_pg_12_static_summary.dart --output FILE INPUT...',
    );
    exitCode = 64;
    return;
  }

  final output = File(arguments[1]);
  final inputs = arguments.skip(2).map(File.new).toList();
  final rows = await _readRows(inputs);
  final summary = buildStaticSummary(rows);
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
        throw FormatException(
          'Sample row must be a JSON object: ${input.path}',
        );
      }
      rows.add(decoded);
    }
  }
  return rows;
}

Map<String, Object?> buildStaticSummary(List<Map<String, Object?>> rows) {
  if (rows.isEmpty) throw const FormatException('No measurement samples.');
  final samples = rows.map(StaticMeasurementSample.fromJson).toList();
  final processIds = samples.map((sample) => sample.processId).toSet();
  if (processIds.length != 10) {
    throw FormatException('Expected 10 processes; found ${processIds.length}.');
  }

  final sizes = [
    for (final typeCount in [1, 10, 100])
      _summaryForSize(samples, typeCount, processIds),
  ];
  return {
    'process_count': processIds.length,
    'iterations_per_process_and_size': 30,
    'bootstrap_seed': 20261101,
    'bootstrap_resamples': 10000,
    'sizes': sizes,
  };
}

Map<String, Object?> _summaryForSize(
  List<StaticMeasurementSample> samples,
  int typeCount,
  Set<int> processIds,
) {
  final sizeSamples = samples
      .where((sample) => sample.typeCount == typeCount)
      .toList();
  if (sizeSamples.length != 300) {
    throw FormatException(
      'Expected 300 samples for $typeCount types; found ${sizeSamples.length}.',
    );
  }
  final processes = <int, List<StaticMeasurementSample>>{
    for (final processId in processIds)
      processId:
          sizeSamples.where((sample) => sample.processId == processId).toList()
            ..sort((left, right) => left.iteration.compareTo(right.iteration)),
  };
  for (final entry in processes.entries) {
    if (entry.value.length != 30 ||
        entry.value.map((sample) => sample.iteration).toSet().length != 30) {
      throw FormatException(
        'Process ${entry.key} must contain iterations 0 through 29 for $typeCount types.',
      );
    }
  }
  return {
    'type_count': typeCount,
    'source_bytes': _singleValue(
      sizeSamples.map((sample) => sample.sourceBytes),
      'source_bytes',
    ),
    'scene_frames_min': sizeSamples
        .map((sample) => sample.sceneFrames)
        .reduce(min),
    'scene_frames_max': sizeSamples
        .map((sample) => sample.sceneFrames)
        .reduce(max),
    'scene_edges_min': sizeSamples
        .map((sample) => sample.sceneEdges)
        .reduce(min),
    'scene_edges_max': sizeSamples
        .map((sample) => sample.sceneEdges)
        .reduce(max),
    'rss_peak_sampled_bytes': sizeSamples
        .map((sample) => sample.rssBytes)
        .reduce(max),
    'metrics': {
      for (final metric in StaticMeasurementSample.metricNames)
        metric: _metricSummary(
          processes.values
              .map((rows) => rows.map((row) => row.metric(metric)).toList())
              .toList(),
        ),
    },
    'breakpoint_candidates': {
      for (final metric in StaticMeasurementSample.metricNames)
        metric: [
          for (final entry in processes.entries)
            for (final candidate in _breakpoints(
              entry.value.map((sample) => sample.metric(metric)).toList(),
            ))
              {
                'process_id': entry.key,
                'split_after_iteration': candidate.$1,
                'relative_change': candidate.$2,
              },
        ],
    },
  };
}

Map<String, Object?> _metricSummary(List<List<int>> processMetrics) {
  final samples = processMetrics.expand((values) => values).toList()..sort();
  final processMeans = processMetrics
      .map(
        (values) =>
            values.reduce((left, right) => left + right) / values.length,
      )
      .toList();
  final confidence = _bootstrapInterval(processMeans);
  return {
    'sample_count': samples.length,
    'minimum_ns': samples.first,
    'median_ns': _percentile(samples, 0.5),
    'p95_ns': _percentile(samples, 0.95),
    'maximum_ns': samples.last,
    'mean_of_process_means_ns':
        processMeans.reduce((a, b) => a + b) / processMeans.length,
    'process_mean_ci95_ns': confidence,
  };
}

List<double> _bootstrapInterval(List<double> processMeans) {
  final random = Random(20261101);
  final means = <double>[];
  for (var sample = 0; sample < 10000; sample++) {
    var total = 0.0;
    for (var index = 0; index < processMeans.length; index++) {
      total += processMeans[random.nextInt(processMeans.length)];
    }
    means.add(total / processMeans.length);
  }
  means.sort();
  return [means[250], means[9749]];
}

List<(int, double)> _breakpoints(List<int> values) {
  final candidates = <(int, double)>[];
  for (var split = 5; split <= values.length - 5; split++) {
    final before = values.take(split).map((value) => value.toDouble()).toList();
    final after = values.skip(split).map((value) => value.toDouble()).toList();
    final beforeMean = _mean(before);
    final afterMean = _mean(after);
    final relative = (afterMean - beforeMean).abs() / max(beforeMean.abs(), 1);
    final standardError = sqrt(
      _variance(before) / before.length + _variance(after) / after.length,
    );
    if (relative > 0.05 &&
        (afterMean - beforeMean).abs() > 3.3 * standardError) {
      candidates.add((split - 1, relative));
    }
  }
  return candidates;
}

double _mean(List<double> values) =>
    values.reduce((left, right) => left + right) / values.length;

double _variance(List<double> values) {
  final mean = _mean(values);
  return values.fold(0.0, (sum, value) => sum + pow(value - mean, 2)) /
      (values.length - 1);
}

int _percentile(List<int> values, double percentile) =>
    values[(values.length * percentile).ceil() - 1];

int _singleValue(Iterable<int> values, String field) {
  final uniqueValues = values.toSet();
  if (uniqueValues.length != 1) {
    throw FormatException('Samples disagree on $field: $uniqueValues.');
  }
  return uniqueValues.single;
}

final class StaticMeasurementSample {
  final int processId;
  final int iteration;
  final int typeCount;
  final int sourceBytes;
  final int viewLoadNs;
  final int sceneBuildNs;
  final int layoutNs;
  final int paintRecordNs;
  final int viewOperations;
  final int sceneOperations;
  final int sceneFrames;
  final int sceneEdges;
  final int rssBytes;

  const StaticMeasurementSample({
    required this.processId,
    required this.iteration,
    required this.typeCount,
    required this.sourceBytes,
    required this.viewLoadNs,
    required this.sceneBuildNs,
    required this.layoutNs,
    required this.paintRecordNs,
    required this.viewOperations,
    required this.sceneOperations,
    required this.sceneFrames,
    required this.sceneEdges,
    required this.rssBytes,
  });

  static const metricNames = [
    'view_load_ns',
    'scene_build_ns',
    'layout_ns',
    'paint_record_ns',
  ];

  factory StaticMeasurementSample.fromJson(Map<String, Object?> json) {
    final sample = StaticMeasurementSample(
      processId: _integer(json, 'process_id'),
      iteration: _integer(json, 'iteration'),
      typeCount: _integer(json, 'type_count'),
      sourceBytes: _integer(json, 'source_bytes'),
      viewLoadNs: _integer(json, 'view_load_ns'),
      sceneBuildNs: _integer(json, 'scene_build_ns'),
      layoutNs: _integer(json, 'layout_ns'),
      paintRecordNs: _integer(json, 'paint_record_ns'),
      viewOperations: _integer(json, 'view_operations'),
      sceneOperations: _integer(json, 'scene_operations'),
      sceneFrames: _integer(json, 'scene_frames'),
      sceneEdges: _integer(json, 'scene_edges'),
      rssBytes: _integer(json, 'rss_bytes'),
    );
    if (![1, 10, 100].contains(sample.typeCount) ||
        sample.iteration < 0 ||
        sample.iteration > 29 ||
        sample.viewLoadNs <= 0 ||
        sample.sceneBuildNs <= 0 ||
        sample.layoutNs <= 0 ||
        sample.paintRecordNs <= 0 ||
        sample.viewOperations != 4 ||
        sample.sceneOperations != 4 ||
        sample.sceneFrames != sample.typeCount + 1 ||
        sample.sceneEdges != sample.typeCount ||
        sample.rssBytes <= 0) {
      throw FormatException('Invalid static measurement sample: $json');
    }
    return sample;
  }

  int metric(String name) => switch (name) {
    'view_load_ns' => viewLoadNs,
    'scene_build_ns' => sceneBuildNs,
    'layout_ns' => layoutNs,
    'paint_record_ns' => paintRecordNs,
    _ => throw ArgumentError.value(name, 'name'),
  };
}

int _integer(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is int) return value;
  throw FormatException('Sample field $field must be an integer.');
}
