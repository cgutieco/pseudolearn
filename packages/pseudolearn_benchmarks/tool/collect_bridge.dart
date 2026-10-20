import 'dart:convert';
import 'dart:io';

import 'bridge_statistics.dart';
import 'bridge_pairs.dart';
import 'capture_bridge_artifacts.dart' show sha256;
import 'bridge_process.dart';
import 'measurement_environment.dart';

Future<void> main(List<String> arguments) async {
  try {
    if (arguments.length != 2) {
      throw const FormatException(
        'Usage: collect_bridge.dart <campaign.json> <new-output-directory>',
      );
    }
    await collectBridge(File(arguments.first), Directory(arguments.last));
  } on Object catch (error) {
    stderr.writeln('Bridge collection failed: $error');
    exitCode = 1;
  }
}

Future<void> collectBridge(File configuration, Directory output) async {
  if (output.existsSync()) {
    throw const FormatException('Output directory already exists');
  }
  final source = await configuration.readAsString();
  final campaign = jsonDecode(source) as Map<String, Object?>;
  final workers = (campaign['workers'] as List<Object?>)
      .cast<Map<String, Object?>>();
  if (workers.isEmpty) throw const FormatException('No bridge workers');
  await output.create(recursive: true);
  await File('${output.path}/campaign.json').writeAsString(source);
  final provenance = await environment();
  provenance['rust'] = await checked('rustc', ['-vV']);
  provenance['timeUnit'] = 'nanoseconds';
  provenance['workspace_source_hashes'] = await _sourceHashes();
  await _save(output, 'capture', provenance);
  await _prepare(campaign, output);
  await _save(output, 'release-artifacts', [
    for (final path
        in (campaign['release_artifacts'] as List<Object?>).cast<String>())
      {
        'path': path,
        'bytes': await File(path).length(),
        'sha256': await sha256(path),
      },
  ]);
  final records = <Map<String, Object?>>[];
  for (var process = 0; process < 10; process++) {
    final ordered = process.isEven ? workers : workers.reversed;
    for (final worker in ordered) {
      await _collectWorker(worker, process, records, output);
    }
  }
  await _save(output, 'summary', {
    'measurements': summarizeBridge(records),
    'paired_bridge_direct': pairedBridgeRatios(records),
    'platform': campaign['platform'],
    'hardware': provenance['hardware'],
    'certification': 'requires_platform_and_frame_review',
    'frame_measurements': campaign['frame_measurements'],
  });
}

Future<void> _collectWorker(
  Map<String, Object?> worker,
  int process,
  List<Map<String, Object?>> records,
  Directory output,
) async {
  final command = (worker['command'] as List<Object?>).cast<String>();
  final scenarios = (worker['scenarios'] as List<Object?>)
      .cast<Map<String, Object?>>();
  if (command.isEmpty || scenarios.isEmpty) {
    throw const FormatException('Invalid bridge worker');
  }
  final child = await Process.start(
    command.first,
    command.skip(1).toList(),
    workingDirectory: worker['directory'] as String?,
  );
  final stdoutText = child.stdout.transform(utf8.decoder).join();
  final stderrText = child.stderr.transform(utf8.decoder).join();
  child.stdin.write(jsonEncode({'iterations': 30, 'scenarios': scenarios}));
  await child.stdin.close();
  final metrics = await observeBridgeProcess(child);
  final status = metrics['exit_code'];
  await _save(output, '${worker['variant']}-$process', {
    ...metrics,
    'stderr': await stderrText,
    'stdout': await stdoutText,
  });
  if (status != 0) {
    throw StateError('Bridge worker failed: ${worker['variant']}');
  }
  final rows = const LineSplitter()
      .convert(await stdoutText)
      .map((line) => jsonDecode(line) as Map<String, Object?>)
      .toList();
  validateBridgeRows(rows, {
    for (final scenario in scenarios)
      scenario['id'] as String: (scenario['timed'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(
            (step) => step['label'] as String? ?? step['operation'] as String,
          )
          .toList(),
  });
  final families = {
    for (final scenario in scenarios)
      scenario['id']: scenario['family'] ?? 'behavior',
  };
  records.addAll(
    rows.map(
      (row) => {
        ...row,
        'variant': worker['variant'],
        'process': process,
        'family': families[row['scenario']],
      },
    ),
  );
  await _save(output, 'raw', records);
}

void validateBridgeRows(
  List<Map<String, Object?>> rows,
  Map<String, List<String>> scenarios,
) {
  final covered = <String, Set<int>>{};
  final identities = <String>{};
  for (final row in rows) {
    final scenario = row['scenario'] as String;
    final iteration = row['iteration'] as int;
    final identity = '$scenario/$iteration/${row['request']}';
    if (!identities.add(identity) ||
        row['request'] is! int ||
        !scenarios.containsKey(scenario) ||
        iteration < 0 ||
        iteration >= 30 ||
        row['verified'] != true ||
        row['operation'] is! String ||
        (row['request'] as int) < 0 ||
        (row['request'] as int) >= (scenarios[scenario]?.length ?? 0) ||
        scenarios[scenario]?[row['request'] as int] != row['operation'] ||
        row['nanoseconds'] is! num ||
        (row['nanoseconds'] as num) < 0 ||
        !(row['nanoseconds'] as num).isFinite) {
      throw const FormatException('Invalid bridge measurement');
    }
    covered.putIfAbsent(scenario, () => {}).add(iteration);
  }
  if (identities.length !=
          scenarios.values.fold<int>(
            0,
            (sum, operations) => sum + operations.length * 30,
          ) ||
      covered.length != scenarios.length ||
      covered.values.any((rounds) => rounds.length != 30)) {
    throw const FormatException('Incomplete bridge process');
  }
}

Future<void> _save(Directory output, String name, Object value) =>
    File('${output.path}/$name.json').writeAsString(jsonEncode(value));

Future<void> _prepare(Map<String, Object?> campaign, Directory output) async {
  final commands = (campaign['prepare'] as List<Object?>? ?? const [])
      .cast<Map<String, Object?>>();
  for (var index = 0; index < commands.length; index++) {
    final step = commands[index];
    final command = (step['command'] as List<Object?>).cast<String>();
    final result = await Process.run(
      command.first,
      command.skip(1).toList(),
      workingDirectory: step['directory'] as String?,
    );
    await _save(output, 'prepare-$index', {
      'command': command,
      'exit_code': result.exitCode,
      'stdout': result.stdout,
      'stderr': result.stderr,
    });
    if (result.exitCode != 0) throw StateError('Bridge build failed');
  }
}

Future<Map<String, String>> _sourceHashes() async {
  final listing = await checked('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '--',
    '../pseudolearn_engine',
    '../pseudolearn_spec/specifications/export.json',
    '../../apps/pseudolearn_app/lib',
    '../../apps/pseudolearn_app/native',
    '../../apps/pseudolearn_app/tool',
    'tool',
  ]);
  return {
    for (final path
        in const LineSplitter()
            .convert(listing)
            .where((path) => File(path).existsSync()))
      path: await checked('git', ['hash-object', '--', path]),
  };
}
