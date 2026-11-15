import 'package:flutter_test/flutter_test.dart';
import '../../tool/bridge_benchmark_script.dart';
import '../fakes/fake_rust_transport.dart';

void main() {
  test(
    'measures requests only after setup and verifies independently',
    () async {
      final transport = FakeRustTransport({
        'version': (_) => {'version': 'fixture'},
      });
      final script = BridgeBenchmarkScript(transport);
      final rows = await script.run({
        'setup': [
          {
            'operation': 'version',
            'arguments': <String, Object?>{},
            'save': 'prepared',
          },
        ],
        'timed': [
          {'operation': 'version', 'arguments': <String, Object?>{}},
        ],
        'expected': {'last.version': 'fixture', 'prepared.version': 'fixture'},
      });
      expect(rows, hasLength(1));
      expect(rows.single['nanoseconds'], isNonNegative);
      await script.close();
    },
  );

  test('rejects incorrect expected output and missing references', () async {
    final script = BridgeBenchmarkScript(
      FakeRustTransport({
        'version': (_) => {'version': 'fixture'},
      }),
    );
    await expectLater(
      script.run({
        'timed': [
          {'operation': 'version', 'arguments': <String, Object?>{}},
        ],
        'expected': {'last.version': 'wrong'},
      }),
      throwsFormatException,
    );
    await expectLater(
      script.run({
        'timed': [
          {
            'operation': 'version',
            'arguments': {'resource': r'$missing'},
          },
        ],
        'expected': {'last.version': 'fixture'},
      }),
      throwsFormatException,
    );
    await script.close();
  });
}
