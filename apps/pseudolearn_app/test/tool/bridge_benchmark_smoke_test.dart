import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

import '../../tool/bridge_benchmark_script.dart';

void main() {
  test(
    'generated API scenarios and a reduced recursive model satisfy expectations',
    () async {
      final directory = await Directory.systemTemp.createTemp('bridge-smoke');
      try {
        final path = '${directory.path}/campaign.json';
        final generated = await Process.run('dart', [
          'run',
          'tool/create_bridge_campaign.dart',
          path,
        ], workingDirectory: '../../packages/pseudolearn_benchmarks');
        expect(generated.exitCode, 0, reason: '${generated.stderr}');
        final campaign =
            jsonDecode(await File(path).readAsString()) as Map<String, Object?>;
        final workers = (campaign['workers'] as List<Object?>)
            .cast<Map<String, Object?>>();
        for (final worker in workers) {
          if (worker['variant'] == 'direct') continue;
          for (final scenario
              in (worker['scenarios'] as List<Object?>)
                  .cast<Map<String, Object?>>()) {
            final id = scenario['id'] as String;
            if (!{
              'payload-16',
              'fibonacci20',
              'retained-event',
              'suspended-input',
              'long-execution-cancel',
              'multidimensional-visible-page',
              'fibonacci20-visible',
            }.contains(id)) {
              continue;
            }
            if (id == 'fibonacci20-visible') {
              final setup = (scenario['setup'] as List<Object?>)
                  .cast<Map<String, Object?>>();
              final arguments =
                  setup.first['arguments'] as Map<String, Object?>;
              arguments['program'] = (arguments['program'] as String)
                  .replaceFirst('Fib(20)', 'Fib(4)');
              (scenario['expected'] as Map<String, Object?>)['last.output'] = [
                '3',
              ];
            }
            final script = BridgeBenchmarkScript(openNativeTransport());
            try {
              final rows = await script.run(scenario);
              expect(rows, isNotEmpty, reason: '${scenario['id']}');
            } catch (error) {
              fail('${scenario['id']}: $error');
            } finally {
              await script.close();
            }
          }
        }
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
