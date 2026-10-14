import 'dart:convert';
import 'dart:io';

import 'statistics.dart';

void main(List<String> arguments) {
  try {
    if (arguments.length != 1) {
      throw const FormatException(
        'Usage: dart run tool/summarize.dart <results>',
      );
    }
    final root = arguments.single;
    final rows =
        jsonDecode(File('$root/raw.json').readAsStringSync()) as List<dynamic>;
    final records = rows.cast<Map<String, dynamic>>();
    final summaryFile = File('$root/summary.json');
    final summary =
        jsonDecode(summaryFile.readAsStringSync()) as Map<String, dynamic>;
    summary['measurements'] = summarize(records);
    summary['observationRatios'] = observationRatios(records);
    summaryFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(summary),
    );
  } on Object catch (error) {
    stderr.writeln('Summary failed: $error');
    exitCode = 1;
  }
}
