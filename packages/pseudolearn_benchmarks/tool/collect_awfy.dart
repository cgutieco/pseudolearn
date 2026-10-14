import 'dart:convert';
import 'dart:io';

import 'collect.dart' show environment, checked, collectProcess;
import 'statistics.dart';

Future<void> main() async {
  try {
    final provenance = await environment();
    const output = 'results/macos-r3-awfy';
    await Directory(output).create(recursive: true);
    await File('$output/capture.json').writeAsString(jsonEncode(provenance));
    await Directory('build').create(recursive: true);
    await checked('dart', [
      'compile',
      'exe',
      'bin/awfy_worker.dart',
      '-o',
      'build/awfy',
    ]);
    final records = <Map<String, dynamic>>[];
    final processes = <Map<String, Object>>[];
    for (var process = 0; process < 10; process++) {
      stdout.writeln('AWFY reference: process ${process + 1}/10');
      processes.add(
        await collectProcess(
          'native',
          process,
          records,
          worker: 'awfy',
          expectedRows: 600,
        ),
      );
      await File('$output/raw.json').writeAsString(jsonEncode(records));
      await File('$output/processes.json').writeAsString(jsonEncode(processes));
    }
    await File('$output/summary.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'environment': provenance,
        'measurements': summarize(records),
        'observationRatios': observationRatios(records),
        'limitations': [
          'Local frequency and external load are uncontrolled',
          'All samples retained; stationarity is not proven',
          'Stopwatch durations use microseconds; sub-resolution samples are retained',
        ],
      }),
    );
  } on Object catch (error) {
    stderr.writeln('AWFY collection failed: $error');
    exitCode = 1;
  }
}
