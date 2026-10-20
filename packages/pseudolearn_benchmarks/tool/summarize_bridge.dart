import 'dart:convert';
import 'dart:io';

import 'bridge_pairs.dart';
import 'bridge_statistics.dart';

Future<void> main(List<String> arguments) async {
  try {
    if (arguments.length != 1) {
      throw const FormatException('Expected raw bridge measurements');
    }
    final rows = (jsonDecode(
      await File(arguments.single).readAsString(),
    ) as List<Object?>).cast<Map<String, Object?>>();
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'measurements': summarizeBridge(rows),
        'paired_bridge_direct': pairedBridgeRatios(rows),
      }),
    );
  } on Object catch (error) {
    stderr.writeln('Bridge summary failed: $error');
    exitCode = 1;
  }
}
