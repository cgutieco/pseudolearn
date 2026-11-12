import 'package:flutter_test/flutter_test.dart';
import '../../fakes/native_test_engine.dart';

const String _program = '''
Algoritmo P
  Definir stream Como Canal<Entero> <- Canal(2);
  Tareas
    Aguardar stream.Enviar(7);
    stream.Cerrar();
  FinTareas
FinAlgoritmo
''';

Map<String, Object?> _map(Object? value) => (value as Map).cast();

int _execution() {
  final analysis = _map(testTransport.call('create_analysis', {
    'program': _program,
  }));
  final started = _map(testTransport.call('start', {
    'analysis': analysis['resource'],
  }));
  final resource = started['resource']! as int;
  testTransport.call('advance', {'resource': resource, 'batch_size': 4096});
  return resource;
}

Map<String, Object?> _channelAt(int resource, int event) {
  final state = _map(testTransport.call('query_state', {
    'resource': resource,
    'event': event,
  }));
  final frame = _map((state['marcos']! as List).first);
  return _map(_map(_map(frame['variables'])['stream'])['canal']);
}

void main() {
  tearDownAll(closeTestEngine);

  test('the native engine publishes a channel as one value', () {
    final resource = _execution();
    expect(_channelAt(resource, 1), {
      'identidad': 1,
      'capacidad': 2,
      'abierto': true,
      'en_cola': 0,
    });
    expect(_channelAt(resource, 7), {
      'identidad': 1,
      'capacidad': 2,
      'abierto': false,
      'en_cola': 1,
    });
  });
}
