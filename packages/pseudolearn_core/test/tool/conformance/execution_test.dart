import 'package:test/test.dart';

import 'protocol_test.dart' show negotiated, request;

void main() {
  test('preserves invalid input warning before successful retry', () {
    final supplied = request('execute',
        'Algoritmo P\nDefinir value Como Entero;\nLeer value;\nEscribir value;\nFinAlgoritmo\n');
    supplied['inputs'] = ['invalid', '7'];
    final response = negotiated().handle(supplied);
    expect(response['output'], '7\n');
    expect(response['termination'], {'kind': 'completed'});
    final diagnostics = response['diagnostics']! as List<Object?>;
    expect(diagnostics, hasLength(1));
    expect((diagnostics.single! as Map)['code'], 'readValueTypeMismatch');
    expect((diagnostics.single! as Map)['severity'], 'warning');
  });

  test('reports a fatal runtime diagnostic exactly once', () {
    final response = negotiated().handle(
        request('execute', 'Algoritmo P\nEscribir 1 / 0;\nFinAlgoritmo\n'));
    final diagnostics = response['diagnostics']! as List<Object?>;
    expect(diagnostics, hasLength(1));
    expect((diagnostics.single! as Map)['code'], 'divisionByZero');
  });
}
