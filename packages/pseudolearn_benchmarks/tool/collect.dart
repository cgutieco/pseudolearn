import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'process_metrics.dart';
import 'statistics.dart';

Future<void> main(List<String> arguments) async {
  try {
    if (arguments.isNotEmpty &&
        (arguments.length != 2 || arguments.first != '--output')) {
      throw const FormatException(
        'Usage: dart run tool/collect.dart [--output directory]',
      );
    }
    final output = arguments.length == 2 && arguments.first == '--output'
        ? arguments.last
        : 'results/local';
    final provenance = await environment();
    await Directory(output).create(recursive: true);
    await compileTargets();
    final records = <Map<String, dynamic>>[];
    final processes = <Map<String, Object>>[];
    for (final target in ['native', 'js', 'wasm']) {
      for (var invocation = 0; invocation < 10; invocation++) {
        stdout.writeln('$target: process ${invocation + 1}/10');
        final result = await collectProcess(target, invocation, records);
        processes.add(result);
        await File('$output/raw.json').writeAsString(jsonEncode(records));
        await File('$output/processes.json')
            .writeAsString(jsonEncode(processes));
      }
    }
    final summary = {
      'environment': provenance,
      'measurements': summarize(records),
      'observationRatios': observationRatios(records),
      'limitations': [
        'Shared runners and local machines do not control frequency or unrelated load',
        'RSS is sampled, CPU is the last accumulated process reading',
        'Stationarity is not proven; all samples including drift are retained',
      ],
    };
    await File('$output/summary.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(summary));
  } on Object catch (error) {
    stderr.writeln('Collection failed: $error');
    exitCode = 1;
  }
}

Future<void> compileTargets() async {
  await Directory('build').create(recursive: true);
  await checked('dart', [
    'compile',
    'exe',
    'bin/worker.dart',
    '-o',
    'build/worker${Platform.isWindows ? '.exe' : ''}',
  ]);
  await checked('dart', [
    'compile',
    'js',
    '-O2',
    'bin/worker.dart',
    '-o',
    'build/worker.js',
  ]);
  await checked('dart', [
    'compile',
    'wasm',
    'bin/worker.dart',
    '-o',
    'build/worker.wasm',
  ]);
  await File('build/run-wasm.mjs').writeAsString('''import fs from 'node:fs';
import {compile} from './worker.mjs';
const compiled = await compile(fs.readFileSync(new URL('./worker.wasm', import.meta.url)));
const application = await compiled.instantiate({});
application.invokeMain();
''');
}

Future<Map<String, Object>> collectProcess(
  String target,
  int invocation,
  List<Map<String, dynamic>> records, {
  String worker = 'worker',
  int expectedRows = 360,
}) async {
  final executable = target == 'native'
      ? 'build/$worker${Platform.isWindows ? '.exe' : ''}'
      : 'node';
  final arguments = switch (target) {
    'js' => ['build/worker.js'],
    'wasm' => ['build/run-wasm.mjs'],
    _ => <String>[],
  };
  final process = await Process.start(executable, arguments);
  final output = process.stdout.transform(utf8.decoder).join();
  final errors = process.stderr.transform(utf8.decoder).join();
  var peakRss = 0;
  var cpuSeconds = 0.0;
  var samples = 0;
  var finished = false;
  final completion = process.exitCode.then((status) {
    finished = true;
    return status;
  });
  while (!finished) {
    final metrics = await sampleProcess(process.pid);
    if (metrics != null) {
      final rss = metrics['rssBytes']!.toInt();
      if (rss > peakRss) peakRss = rss;
      cpuSeconds = metrics['cpuSeconds']!.toDouble();
      samples++;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  if (await completion != 0) throw StateError(await errors);
  final rows = const LineSplitter()
      .convert(await output)
      .map((line) => jsonDecode(line) as Map<String, dynamic>)
      .toList();
  if (rows.length != expectedRows ||
      samples == 0 ||
      rows.any((row) => row.containsKey('error'))) {
    throw StateError('Incomplete measurement: $target');
  }
  records.addAll(
    rows.map((row) => {...row, 'target': target, 'process': invocation}),
  );
  return {
    'target': target,
    'process': invocation,
    'peakRssSampledBytes': peakRss,
    'lastCpuSampleSeconds': cpuSeconds,
    'metricSamples': samples,
  };
}

Future<String> checked(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) throw StateError('${result.stderr}');
  return '${result.stdout}'.trim();
}

Future<Map<String, Object>> environment() async => {
  'commit': await checked('git', ['rev-parse', 'HEAD']),
  'sourceHashes': await sourceHashes(),
  'clockFrequency': Stopwatch().frequency,
  'timeUnit': 'microseconds',
  'dirty': (await checked('git', [
    'status',
    '--porcelain',
    '--untracked-files=no',
    '--',
    'lib',
    'bin',
    'tool',
    'pubspec.yaml',
    'node-version',
    'architecture.yaml',
  ])).isNotEmpty,
  'dart': await checked('dart', ['--version']),
  'node': await checked('node', ['--version']),
  'os': Platform.operatingSystem,
  'osVersion': Platform.operatingSystemVersion,
  'cpuCount': Platform.numberOfProcessors,
  'hardware': await hardware(),
  'utc': DateTime.now().toUtc().toIso8601String(),
  'processesPerTarget': 10,
  'iterationsPerWorkloadAndMode': 30,
  'seed': 42,
};

Future<String> hardware() async {
  if (Platform.isMacOS) {
    return checked('sysctl', [
      'hw.model',
      'machdep.cpu.brand_string',
      'hw.memsize',
    ]);
  }
  if (Platform.isLinux) {
    return '${await checked('lscpu', [])}\n${await File('/proc/meminfo').readAsString()}';
  }
  return checked('powershell', [
    '-NoProfile',
    '-Command',
    'Get-CimInstance Win32_Processor | Select-Object Name; '
        'Get-CimInstance Win32_ComputerSystem | Select-Object TotalPhysicalMemory',
  ]);
}

Future<Map<String, String>> sourceHashes() async {
  final listing = await checked('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '--',
    'lib',
    'bin',
    'tool',
    'pubspec.yaml',
    'architecture.yaml',
  ]);
  return {
    for (final path in const LineSplitter().convert(listing))
      path: await checked('git', ['hash-object', '--', path]),
  };
}
