import 'dart:convert';
import 'dart:io';

import 'conformance/protocol.dart';

Future<void> main() async {
  final manifest = File.fromUri(Platform.script.resolve('../pubspec.yaml'))
      .readAsStringSync();
  final version = RegExp(r'^version: (.+)$', multiLine: true)
      .firstMatch(manifest)
      ?.group(1);
  if (version == null) {
    stderr.writeln('Missing subject version');
    exitCode = 1;
    return;
  }
  final protocol = ReferenceProtocol(subjectVersion: version);
  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Request must be a JSON object');
      }
      final request = Map<String, Object?>.from(decoded);
      final response = protocol.handle(request);
      stdout.writeln(jsonEncode(response));
      if (request['kind'] == 'shutdown') break;
    } on Object catch (error) {
      stdout.writeln(jsonEncode({'kind': 'error', 'error': error.toString()}));
    }
  }
}
