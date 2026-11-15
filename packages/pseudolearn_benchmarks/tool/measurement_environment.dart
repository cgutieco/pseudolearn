import 'dart:async';
import 'dart:convert';

import 'process_metrics.dart';

import 'dart:io';

Future<Map<String, Object>> collectProcess(
  String target,
  int invocation,
  List<Map<String, dynamic>> records, {
  required String worker,
  int expectedRows = 360,
  List<String> workerArguments = const [],
}) async {
  final executable = 'build/$worker${Platform.isWindows ? '.exe' : ''}';
  final arguments = workerArguments;
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
    for (final path
        in const LineSplitter()
            .convert(listing)
            .where((path) => File(path).existsSync()))
      path: await checked('git', ['hash-object', '--', path]),
  };
}
