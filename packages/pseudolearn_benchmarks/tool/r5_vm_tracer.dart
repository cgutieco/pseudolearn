import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

import 'change_points.dart' show detectChangePoints;
import 'statistics.dart' show confidenceInterval;

const _iterationsPerProcess = 30;
const _maximumSteps = 10000000;
const _workloadsPath = 'tool/data/r5-vm-workloads.json';

Future<void> main(List<String> arguments) async {
  try {
    if (arguments.isEmpty) {
      await _collect();
      return;
    }
    if (arguments.length != 3 || arguments.first != 'worker') {
      throw const FormatException(
        'Usage: dart run tool/r5_vm_tracer.dart [worker <workload> <process>]',
      );
    }
    final process = int.tryParse(arguments[2]);
    if (process == null || process < 0 || process >= 10) {
      throw const FormatException('Process index must be between 0 and 9');
    }
    stdout.writeln(jsonEncode(await _runWorker(arguments[1], process)));
  } on Object catch (error) {
    stderr.writeln('R5 VM tracer failed: $error');
    exitCode = 1;
  }
}

Future<Map<String, Object>> _runWorker(String identifier, int process) async {
  final workload = _loadWorkload(identifier);
  final program = analyze(workload.source);
  if (program == null) {
    throw StateError('Reference analysis failed: $identifier');
  }
  final preflight = _execute(program, workload.expectedOutput);
  if (!preflight.valid) {
    throw StateError(
      'Reference preflight failed: $identifier: ${preflight.error}',
    );
  }
  final samples = <Map<String, Object>>[];
  for (var iteration = 0; iteration < _iterationsPerProcess; iteration++) {
    final sample = _execute(program, workload.expectedOutput);
    if (!sample.valid) {
      throw StateError(
        'Reference execution failed: $identifier: ${sample.error}',
      );
    }
    samples.add({
      'iteration': iteration,
      'nanoseconds': sample.nanoseconds,
      'validated': true,
    });
  }
  return {
    'backend': 'reference',
    'workload': identifier,
    'process': process,
    'samples': samples,
  };
}

({bool valid, int nanoseconds, String? error}) _execute(
  AnalyzedProgram program,
  String expectedOutput,
) {
  final start = Interpreter.start(
    program: program,
    random: SeededRandomSource(42),
  );
  if (start is! ExecutionReady) {
    return (valid: false, nanoseconds: 0, error: 'program is not executable');
  }
  final output = StringBuffer();
  final stopwatch = Stopwatch()..start();
  for (var step = 0; step < _maximumSteps; step++) {
    final outcome = start.interpreter.step();
    if (outcome is StepFinished) {
      stopwatch.stop();
      final valid = output.toString().trim() == expectedOutput;
      final nanoseconds =
          stopwatch.elapsedTicks * 1000000000 ~/ Stopwatch().frequency;
      return (
        valid: valid && nanoseconds > 0,
        nanoseconds: nanoseconds,
        error: valid ? null : 'output differs from the expected result',
      );
    }
    if (outcome is StepHalted) {
      stopwatch.stop();
      return (
        valid: false,
        nanoseconds: 0,
        error: outcome.diagnostic.code.name,
      );
    }
    if (outcome is StepAwaitingInput) {
      stopwatch.stop();
      return (valid: false, nanoseconds: 0, error: 'unexpected input request');
    }
    if (outcome case StepAdvanced(:final events)) {
      for (final event in events.whereType<OutputProducedEvent>()) {
        output.write(event.text);
      }
    }
  }
  stopwatch.stop();
  return (valid: false, nanoseconds: 0, error: 'execution step limit exceeded');
}

Workload _loadWorkload(String identifier) {
  final document = jsonDecode(File(_workloadsPath).readAsStringSync());
  if (document is! Map<String, dynamic> || document['workloads'] is! List) {
    throw const FormatException('Workload dataset is invalid');
  }
  for (final entry in document['workloads'] as List) {
    if (entry is Map<String, dynamic> && entry['id'] == identifier) {
      final inputs = entry['inputs'];
      if (inputs is! List || inputs.isNotEmpty) {
        throw const FormatException('R5 workloads must not require inputs');
      }
      final source = entry['source'];
      final expectedOutput = entry['expectedOutput'];
      if (source is! String || expectedOutput is! String) {
        throw const FormatException(
          'Workload source or expected output is invalid',
        );
      }
      return Workload(
        name: identifier,
        family: 'r5-vm',
        source: source,
        expectedOutput: expectedOutput,
        operations: 1,
      );
    }
  }
  throw FormatException('Unknown workload: $identifier');
}

Future<void> _collect() async {
  final provenance = await _captureProvenance();
  final outputDirectory = Directory('results/r5-vm-tracer');
  final specDirectory = Directory('../pseudolearn_spec/results');
  await outputDirectory.create(recursive: true);
  await specDirectory.create(recursive: true);
  await File('${outputDirectory.path}/capture.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(provenance));
  final dart = Platform.environment['DART'] ?? 'dart';
  await checked(dart, [
    'compile',
    'exe',
    'tool/r5_vm_tracer.dart',
    '-o',
    'build/r5-vm-reference-worker${Platform.isWindows ? '.exe' : ''}',
  ]);
  final cargo = Platform.environment['CARGO'] ?? 'cargo';
  await checked(cargo, [
    'build',
    '--release',
    '-p',
    'pseudolearn_vm_tracer',
    '--bin',
    'vm-tracer',
  ], workingDirectory: '../pseudolearn_engine');
  final referenceWorker =
      'build/r5-vm-reference-worker${Platform.isWindows ? '.exe' : ''}';
  final vmWorker =
      '${Directory('../pseudolearn_engine').absolute.path}/target/release/vm-tracer${Platform.isWindows ? '.exe' : ''}';
  final records = <Map<String, Object>>[];
  final processRecords = <Map<String, Object>>[];
  const workloadIds = [
    'mandelbrot-8',
    'integer-loop-10000',
    'recursive-fibonacci-18',
  ];
  for (final workload in workloadIds) {
    for (var process = 0; process < 10; process++) {
      for (final backend in ['reference', 'vm']) {
        final executable = backend == 'reference'
            ? File(referenceWorker).absolute.path
            : vmWorker;
        final arguments = backend == 'reference'
            ? ['worker', workload, '$process']
            : [
                'worker',
                '../pseudolearn_benchmarks/tool/data/r5-vm-workloads.json',
                workload,
                '$process',
                '../pseudolearn_benchmarks/tool/data/r5-vm-superinstructions.json',
              ];
        final started = DateTime.now().toUtc();
        final result = await Process.run(
          executable,
          arguments,
          workingDirectory: backend == 'reference'
              ? Directory.current.absolute.path
              : Directory('../pseudolearn_engine').absolute.path,
        );
        if (result.exitCode != 0) {
          throw StateError('$backend/$workload/$process: ${result.stderr}');
        }
        final worker = jsonDecode('${result.stdout}');
        if (worker is! Map<String, dynamic> ||
            worker['backend'] != backend ||
            worker['workload'] != workload ||
            worker['process'] != process ||
            worker['samples'] is! List) {
          throw StateError(
            'Worker returned invalid metadata: $backend/$workload/$process',
          );
        }
        final samples = worker['samples'] as List;
        if (samples.length != _iterationsPerProcess) {
          throw StateError(
            'Worker returned an incomplete process: $backend/$workload/$process',
          );
        }
        for (var iteration = 0; iteration < samples.length; iteration++) {
          final sample = samples[iteration];
          if (sample is! Map<String, dynamic> ||
              sample['iteration'] != iteration ||
              sample['validated'] != true ||
              sample['nanoseconds'] is! int ||
              (sample['nanoseconds'] as int) <= 0) {
            throw StateError(
              'Worker returned an invalid sample: $backend/$workload/$process/$iteration',
            );
          }
          records.add({
            'backend': backend,
            'workload': workload,
            'process': process,
            'iteration': iteration,
            'nanoseconds': sample['nanoseconds'] as int,
            'validated': true,
          });
        }
        processRecords.add({
          'backend': backend,
          'workload': workload,
          'process': process,
          'startedAtUtc': started.toIso8601String(),
          'samples': samples.length,
        });
        await File('${outputDirectory.path}/raw.json')
            .writeAsString(const JsonEncoder.withIndent('  ').convert(records));
        await File('${outputDirectory.path}/processes.json').writeAsString(
          const JsonEncoder.withIndent('  ').convert(processRecords),
        );
      }
    }
  }
  final summary = _summarize(records, provenance);
  await File('${outputDirectory.path}/summary.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(summary));
  await File('${specDirectory.path}/r5-vm-tracer.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(summary));
}

Map<String, Object> _summarize(
  List<Map<String, Object>> records,
  Map<String, Object> provenance,
) {
  final workloadSummaries = <String, Object>{};
  final ratios = <double>[];
  for (final workload in const [
    'mandelbrot-8',
    'integer-loop-10000',
    'recursive-fibonacci-18',
  ]) {
    final backendMeans = <String, List<double>>{};
    for (final backend in ['reference', 'vm']) {
      backendMeans[backend] = [
        for (var process = 0; process < 10; process++)
          _mean(
            records
                .where(
                  (record) =>
                      record['backend'] == backend &&
                      record['workload'] == workload &&
                      record['process'] == process,
                )
                .map((record) => (record['nanoseconds'] as int).toDouble())
                .toList(),
          ),
      ];
    }
    final pairedSpeedups = [
      for (var process = 0; process < 10; process++)
        backendMeans['reference']![process] / backendMeans['vm']![process],
    ];
    final logSpeedups = pairedSpeedups.map(math.log).toList();
    final geometricSpeedup = math.exp(_mean(logSpeedups));
    final changePoints = <String, Object>{};
    for (final backend in ['reference', 'vm']) {
      for (var process = 0; process < 10; process++) {
        final samples = records
            .where(
              (record) =>
                  record['backend'] == backend &&
                  record['workload'] == workload &&
                  record['process'] == process,
            )
            .map((record) => (record['nanoseconds'] as int).toDouble())
            .toList();
        changePoints['$backend/$process'] = detectChangePoints(samples);
      }
    }
    ratios.add(geometricSpeedup);
    workloadSummaries[workload] = {
      'referenceMeanNanoseconds': _mean(backendMeans['reference']!),
      'vmMeanNanoseconds': _mean(backendMeans['vm']!),
      'pairedProcessGeometricSpeedup': geometricSpeedup,
      'confidence95': confidenceInterval(logSpeedups).map(math.exp).toList(),
      'speedupsByProcess': pairedSpeedups,
      'changePointCandidatesByBackendProcess': changePoints,
      'stationarity': 'not_proven',
      'samplesPerBackend': 300,
    };
  }
  final overall = math.exp(_mean(ratios.map(math.log).toList()));
  return {
    'protocol': 'PERF.PROTOCOL',
    'environment': provenance,
    'workloads': workloadSummaries,
    'geometricMeanSpeedup': overall,
    'targetSpeedup': 30,
    'targetMet': overall >= 30,
    'samplesDiscarded': 0,
    'timing': 'nanoseconds; compilation and result validation excluded',
    'limitations': [
      'Stationarity is not proven; candidate change points retain all samples',
      'Local CPU frequency and unrelated system load are uncontrolled',
    ],
  };
}

double _mean(List<double> values) =>
    values.reduce((left, right) => left + right) / values.length;

Future<Map<String, Object>> _captureProvenance() async {
  final cargo = Platform.environment['CARGO'] ?? 'cargo';
  final rustc = Platform.environment['RUSTC'] ?? 'rustc';
  final dart = Platform.environment['DART'] ?? 'dart';
  final provenance = <String, Object>{
    'sourceHashes': await _sourceHashes(),
    'dirtyTree': (await checked('git', [
      'status',
      '--porcelain',
      '--untracked-files=all',
    ])).isNotEmpty,
    'commit': await checked('git', ['rev-parse', 'HEAD']),
    'dart': await checked(dart, ['--version']),
    'rustc': await checked(rustc, ['--version']),
    'cargo': await checked(cargo, ['--version']),
    'os': Platform.operatingSystem,
    'osVersion': Platform.operatingSystemVersion,
    'cpuCount': Platform.numberOfProcessors,
    'hardware': await _hardware(),
    'utc': DateTime.now().toUtc().toIso8601String(),
    'processesPerBackendAndWorkload': 10,
    'iterationsPerProcess': _iterationsPerProcess,
    'tool': 'B3.3 direct VM and frozen reference tracer',
    'rustFlags': Platform.environment['RUSTFLAGS'] ?? '',
  };
  final profilePath = Platform.environment['R5_PGO_PROFILE'];
  if (profilePath != null) {
    final hashOutput = await checked('shasum', ['-a', '256', profilePath]);
    provenance['pgoProfile'] = {
      'path': profilePath,
      'sha256': hashOutput.split(' ').first,
    };
  }
  return provenance;
}

Future<String> _hardware() async {
  try {
    if (Platform.isMacOS) {
      return await checked('sysctl', [
        'hw.model',
        'machdep.cpu.brand_string',
        'hw.memsize',
      ]);
    }
    if (Platform.isLinux) return await checked('lscpu', []);
    return await checked('powershell', [
      '-NoProfile',
      '-Command',
      'Get-CimInstance Win32_Processor | Select-Object Name; '
          'Get-CimInstance Win32_ComputerSystem | Select-Object TotalPhysicalMemory',
    ]);
  } on Object {
    return 'unavailable; ${Platform.operatingSystemVersion}';
  }
}

Future<Map<String, String>> _sourceHashes() async {
  final repositoryRoot = await checked('git', ['rev-parse', '--show-toplevel']);
  final listing = await checked('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '--',
    ':(top)packages/pseudolearn_engine/Cargo.toml',
    ':(top)packages/pseudolearn_engine/rust-toolchain.toml',
    ':(top)packages/pseudolearn_engine/crates',
    ':(top)packages/pseudolearn_benchmarks/tool',
    ':(top)packages/pseudolearn_benchmarks/architecture.yaml',
    ':(top)packages/pseudolearn_benchmarks/pubspec.yaml',
    ':(top)packages/pseudolearn_core/lib',
    ':(top)packages/pseudolearn_core/pubspec.yaml',
  ], workingDirectory: repositoryRoot);
  return {
    for (final path in const LineSplitter().convert(listing))
      path: await checked('git', [
        'hash-object',
        '--',
        path,
      ], workingDirectory: repositoryRoot),
  };
}

Future<String> checked(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) throw StateError('${result.stderr}');
  return '${result.stdout}'.trim();
}
