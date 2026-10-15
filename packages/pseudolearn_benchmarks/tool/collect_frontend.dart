import 'dart:convert';
import 'dart:io';

import 'collect.dart';
import 'frontend_statistics.dart';

Future<void> main(List<String> arguments) async {
  try {
    final output = arguments.isEmpty ? 'results/e08r' : arguments.single;
    final provenance = await frontendEnvironment();
    await Directory(output).create(recursive: true);
    await Directory('build').create(recursive: true);
    await save(output, 'capture', provenance);
    await checked('cargo', [
      'build',
      '--release',
      '--manifest-path',
      '../pseudolearn_engine/Cargo.toml',
      '-p',
      'pseudolearn_bench_worker',
    ]);
    final records = <Map<String, dynamic>>[];
    final processes = <Map<String, Object>>[];
    for (var invocation = 0; invocation < 10; invocation++) {
      stdout.writeln('Frontend: process ${invocation + 1}/10');
      processes.add(
        await collectProcess(
          'native',
          invocation,
          records,
          worker: '../../pseudolearn_engine/target/release/pseudolearn_bench_worker',
          workerArguments: ['frontend'],
          expectedRows: 840,
        ),
      );
      await save(output, 'raw', records);
      await save(output, 'processes', processes);
    }
    await save(output, 'summary', {
      'environment': provenance,
      'measurements': summarizeFrontend(records),
      'limitations': [
        'Shared hardware does not control frequency or unrelated load',
        'RSS is a sampled lower bound; CPU is the last accumulated reading',
        'All samples retained; stationarity is not proven',
      ],
    });
  } on Object catch (error) {
    stderr.writeln('Frontend collection failed: $error');
    exitCode = 1;
  }
}

Future<Map<String, Object>> frontendEnvironment() async {
  final provenance = await environment();
  final listing = await checked('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '--',
    '../pseudolearn_engine',
    '../pseudolearn_spec/specifications/export.json',
  ]);
  provenance['engineSourceHashes'] = {
    for (final path in const LineSplitter().convert(listing))
      path: await File(path).exists()
          ? await checked('git', ['hash-object', '--', path])
          : 'DELETED',
  };
  provenance['rustc'] = await checked('rustc', ['--version', '--verbose']);
  provenance['cargo'] = await checked('cargo', ['--version']);
  provenance['timeUnit'] = 'nanoseconds';
  provenance['engineDirty'] = (await checked('git', [
    'status',
    '--porcelain',
    '--',
    '../pseudolearn_engine',
  ])).isNotEmpty;
  return provenance;
}

Future<void> save(String output, String name, Object content) =>
    File('$output/$name.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(content));
