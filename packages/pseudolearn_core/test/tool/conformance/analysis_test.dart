import 'package:test/test.dart';

import '../../../tool/conformance/protocol.dart';
import 'protocol_test.dart' show negotiated, request;

void main() {
  test('transmits inherited resolution diagnostics once without deduplication',
      () {
    final response = negotiated().handle(request(
        'analyze', 'Algoritmo P\nDefinir x Como Entero;\nFinAlgoritmo\n'));
    final diagnostics = response['diagnostics']! as List<Object?>;
    expect(diagnostics, hasLength(1));
    expect((diagnostics.single! as Map)['code'], 'variableDeclaredNeverUsed');
  });

  test(
      'preserves distinct parser diagnostics from the same malformed statement',
      () {
    final ReferenceProtocol protocol = negotiated();
    final response = protocol.handle(
        request('analyze', 'Algoritmo P\nEscribir 1 +\nFinAlgoritmo\n'));
    final diagnostics = response['diagnostics']! as List<Object?>;
    expect(diagnostics, hasLength(2));
    expect(diagnostics.map((value) => (value! as Map)['code']),
        everyElement('expectedExpression'));
  });
}
