import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import '../../tool/see_app_api.dart';
import '../fakes/fake_rust_transport.dart';

void main() {
  test('runs API calls in order and resolves prior resource handles', () {
    final transport = FakeRustTransport({
      'create_analysis': (_) => {'resource': 7, 'document': 11},
      'analysis': (arguments) => {'resource': arguments['resource']},
    });
    final response = executeApiRequest(transport, {
      'calls': [
        {
          'operation': 'create_analysis',
          'arguments': {'program': 'Algoritmo P'},
        },
        {'operation': 'analysis', 'resource_from': 0},
      ],
    });
    expect(transport.calls, ['create_analysis', 'analysis']);
    expect(response, {
      'kind': 'api',
      'results': [
        {
          'value': {'resource': 7, 'document': 11},
        },
        {
          'value': {'resource': 7},
        },
      ],
    });
  });

  test('returns typed failures for failed and malformed API calls', () {
    final transport = FakeRustTransport({
      'negotiate': (_) => throw const RustBridgeFailure(
        family: 'version',
        detail: 'unsupported version',
      ),
    });
    final response = executeApiRequest(transport, {
      'calls': [
        {'operation': 'negotiate', 'arguments': <String, Object?>{}},
        {'operation': 'unknown'},
      ],
    });
    expect(response, {
      'kind': 'api',
      'results': [
        {
          'failure': {'family': 'version'},
        },
        {
          'failure': {'family': 'usage'},
        },
      ],
    });
  });

  test('keeps empty API batches empty', () {
    final transport = FakeRustTransport({});
    expect(executeApiRequest(transport, {'calls': []}), {
      'kind': 'api',
      'results': <Object?>[],
    });
    expect(transport.calls, isEmpty);
  });
}
