import 'package:test/test.dart';

import 'protocol_test.dart' show negotiated, request;

const empty = <String, Object?>{};

Map<String, Object?> observed(String program,
    {List<String> inputs = const []}) {
  final traced = request('execute', program)
    ..['observe'] = 'events'
    ..['inputs'] = inputs;
  return negotiated().handle(traced);
}

List<Map<Object?, Object?>> eventsOf(Map<String, Object?> response) =>
    (response['events']! as List<Object?>).cast<Map<Object?, Object?>>();

void main() {
  test('translates statements and output fragments into the trace alphabet',
      () {
    final events =
        eventsOf(observed('Algoritmo P\nEscribir 1;\nFinAlgoritmo\n'));
    expect(
        events.first, {'class': 'statement_entered', 'line': 2, 'data': empty});
    final text = events
        .where((event) => event['class'] == 'output')
        .map((event) => (event['data']! as Map)['texto'])
        .join();
    expect(text, '1\n');
    expect(
        events.last, {'class': 'statement_exited', 'line': 2, 'data': empty});
  });

  test('records calls, decisions, accepted input and failure events', () {
    const program = 'SubProceso f()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\n'
        'Definir x Como Entero;\nLeer x;\nSi x > 0 Entonces\nf();\nFinSi\n'
        'Escribir 1 div 0;\nFinAlgoritmo\n';
    final events = eventsOf(observed(program, inputs: ['3']));
    final classes = events.map((event) => event['class']).toSet();
    expect(
        classes,
        containsAll(
            ['call', 'return', 'decision', 'input_received', 'failure']));
    expect(events.last, {
      'class': 'failure',
      'line': 10,
      'data': {'codigo': 'divisionByZero'}
    });
  });

  test('keeps the empty trace for an empty algorithm and unobserved runs', () {
    expect(observed('Algoritmo P\nFinAlgoritmo\n')['events'], isEmpty);
    final plain = negotiated()
        .handle(request('execute', 'Algoritmo P\nEscribir 1;\nFinAlgoritmo\n'));
    expect(plain['events'], isEmpty);
  });
}
