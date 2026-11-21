import 'dart:convert';
import 'dart:io';

import 'bridge_benchmark_campaign.dart';

Future<void> main(List<String> arguments) async {
  try {
    if (arguments.length != 1) {
      throw const FormatException(
        'Usage: bridge_benchmark_device_worker.dart <adb-device-id>',
      );
    }
    final source = await stdin.transform(utf8.decoder).join();
    expectedIterations(jsonDecode(source) as Map<String, Object?>);
    await measureOnDevice(arguments.single, source);
  } on Object catch (error) {
    stderr.writeln('Device bridge worker failed: $error');
    exitCode = 1;
  }
}

Future<void> measureOnDevice(String device, String configuration) async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  try {
    await _checked('adb', [
      '-s',
      device,
      'reverse',
      'tcp:${server.port}',
      'tcp:${server.port}',
    ]);
    final rows = server.first.then((peer) => _exchange(peer, configuration));
    final drive = await Process.start('flutter', [
      'drive',
      '--profile',
      '-d',
      device,
      '--driver',
      'test_driver/integration_test.dart',
      '--target',
      'integration_test/bridge_benchmark_test.dart',
      '--dart-define=BRIDGE_CAMPAIGN_PORT=${server.port}',
    ]);
    drive.stdout.listen(stderr.add);
    drive.stderr.listen(stderr.add);
    if (await drive.exitCode != 0) throw StateError('flutter drive failed');
    await rows.timeout(const Duration(seconds: 5));
  } finally {
    await server.close();
    await Process.run('adb', [
      '-s',
      device,
      'reverse',
      '--remove',
      'tcp:${server.port}',
    ]);
  }
}

Future<void> _exchange(Socket peer, String configuration) async {
  peer.writeln(jsonEncode(jsonDecode(configuration)));
  await peer.forEach(stdout.add);
  await peer.close();
}

Future<void> _checked(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    throw StateError('$executable ${arguments.join(' ')}: ${result.stderr}');
  }
}
