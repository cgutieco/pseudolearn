import 'package:test/test.dart';

import '../../../tool/conformance/protocol.dart';

Map<String, Object?> request(String kind, String program,
        {String profile = 'es', String strictness = 'flexible'}) =>
    {
      'kind': kind,
      'program': program,
      'profile': profile,
      'strictness': strictness,
      'inputs': <String>[],
      'seed': 42,
      'observe': 'none',
      'limits': {'micro_steps': 100000},
    };

ReferenceProtocol negotiated() {
  final protocol = ReferenceProtocol(subjectVersion: '0.1.0');
  protocol.handle({'kind': 'hello', 'protocol': 'see-protocol/1'});
  return protocol;
}

void main() {
  test('negotiates capabilities and rejects incompatible requests', () {
    final protocol = ReferenceProtocol(subjectVersion: '0.1.0');
    expect(
        () => protocol.handle(request('analyze', '')), throwsFormatException);
    expect(() => protocol.handle({'kind': 'hello', 'protocol': 'wrong'}),
        throwsFormatException);
    final hello =
        protocol.handle({'kind': 'hello', 'protocol': 'see-protocol/1'});
    expect(hello['subject'], 'reference');
    expect(hello['subject_version'], '0.1.0');
    expect(hello['capabilities'], ['analyze', 'execute']);
    expect(
        () => protocol.handle(request('unknown', '')), throwsFormatException);
    expect(() => protocol.handle(request('analyze', '', profile: 'unknown')),
        throwsFormatException);
    expect(protocol.handle({'kind': 'shutdown'}), {'kind': 'shutdown'});
  });

  test(
      'analyzes a valid empty algorithm in both profiles and strictness policies',
      () {
    final programs = {
      'es': 'Algoritmo P\nFinAlgoritmo\n',
      'en': 'algorithm P\nendAlgorithm\n'
    };
    for (final profile in programs.entries) {
      for (final strictness in ['strict', 'flexible']) {
        final response = negotiated().handle(request('analyze', profile.value,
            profile: profile.key, strictness: strictness));
        expect(response['tree'], true);
        expect(response['diagnostics'], isEmpty);
      }
    }
  });

  test(
      'preserves empty input and diagnostics without inventing an executable tree',
      () {
    final response = negotiated().handle(request('execute', ''));
    expect(response['tree'], false);
    expect(
        response['termination'], {'kind': 'failed', 'code': 'analysisFailed'});
    expect(response['diagnostics'], isNotEmpty);
  });

  test('executes output and returns bounded termination', () {
    final protocol = negotiated();
    final response = protocol
        .handle(request('execute', 'Algoritmo P\n Escribir 7\nFinAlgoritmo\n'));
    expect(response['output'], '7\n');
    expect(response['termination'], {'kind': 'completed'});
    final limited = request('execute',
        'Algoritmo P\n Mientras Verdadero Hacer\n FinMientras\nFinAlgoritmo\n');
    limited['limits'] = {'micro_steps': 20};
    expect(protocol.handle(limited)['termination'],
        {'kind': 'limit_reached', 'limit': 'micro_steps'});
  });

  test('returns awaiting input and consumes supplied input', () {
    const program =
        'Algoritmo P\n Definir value Como Entero\n Leer value\n Escribir value\nFinAlgoritmo\n';
    final protocol = negotiated();
    expect(protocol.handle(request('execute', program))['termination'],
        {'kind': 'awaiting_input'});
    final supplied = request('execute', program);
    supplied['inputs'] = ['23'];
    expect(protocol.handle(supplied)['output'], '23\n');
  });

  test('preserves runtime diagnostic details and rejects invalid limits', () {
    final protocol = negotiated();
    final response = protocol.handle(request('execute',
        'Algoritmo P\n Escribir 9223372036854775807 + 1\nFinAlgoritmo\n'));
    expect(
        response['termination'], {'kind': 'failed', 'code': 'integerOverflow'});
    final invalid = request('execute', 'Algoritmo P\nFinAlgoritmo\n');
    invalid['limits'] = {'micro_steps': 0};
    expect(() => protocol.handle(invalid), throwsFormatException);
    invalid['limits'] = {'micro_steps': 10};
    invalid['observe'] = 'events';
    expect(() => protocol.handle(invalid), throwsFormatException);
  });
}
