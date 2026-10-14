import 'package:test/test.dart';

import 'protocol_test.dart' show negotiated, request;

const threeWrites =
    'Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n';

Map<String, Object?> run(void Function(Map<String, Object?>) configure) {
  final message = request('execute', threeWrites);
  configure(message);
  return negotiated().handle(message);
}

void main() {
  test('cancels at the requested statement entry without its effects', () {
    final cancelled = run((message) => message['cancel_at_statement'] = 3);
    expect(cancelled['output'], '1\n2\n');
    expect(cancelled['termination'], {'kind': 'cancelled'});
    final first = run((message) => message['cancel_at_statement'] = 1);
    expect(first['output'], '');
    final late = run((message) => message['cancel_at_statement'] = 10);
    expect(late['termination'], {'kind': 'completed'});
  });

  test('stops at the statement budget as a host limit', () {
    final limited =
        run((message) => (message['limits']! as Map)['statements'] = 2);
    expect(limited['output'], '1\n2\n');
    expect(limited['termination'],
        {'kind': 'limit_reached', 'limit': 'statements'});
    final exact =
        run((message) => (message['limits']! as Map)['statements'] = 3);
    expect(exact['termination'], {'kind': 'completed'});
  });

  test('answers a state query at an event index', () {
    final queried = run((message) => message
      ..['observe'] = 'events'
      ..['state_at'] = 0);
    final state = queried['state_at']! as Map<String, Object?>;
    expect(state['objetos'], isEmpty);
    expect(state['marcos'], isA<List<Object?>>());
    final outside = run((message) => message['state_at'] = 99);
    expect(outside.containsKey('state_at'), isFalse);
  });

  test('rejects malformed limits, cancellation, indices and observation modes',
      () {
    for (final configure in <void Function(Map<String, Object?>)>[
      (message) => message['cancel_at_statement'] = 0,
      (message) => message['state_at'] = -1,
      (message) => message['limits'] = <String, Object?>{
            'micro_steps': 10,
            'statements': 'many'
          },
      (message) => message['observe'] = 'everything',
    ]) {
      expect(() => run(configure), throwsFormatException);
    }
  });
}
