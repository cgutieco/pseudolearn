import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/simulated_capabilities.dart';
import 'package:pseudolearn_app/domain/model/execution/simulated_scenario.dart';
import 'package:pseudolearn_app/engine/rust/rust_simulated_host.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

Map<String, Object?> capability(int slot, {int rights = 3, int kind = 2}) => {
  'slot': slot,
  'generation': 1,
  'rights': rights,
  'kind': kind,
};

Map<String, Object?> text(String value) => {'kind': 'text', 'value': value};

Map<String, Object?> request(
  String operation, {
  Map<String, Object?>? receiver,
  List<Map<String, Object?>> arguments = const [],
  Map<String, Object?>? result,
}) => {
  'operation': operation,
  'receiver': receiver,
  'arguments': arguments,
  'result_capability': result,
};

String? failureCode(Map<String, Object?> reply) =>
    (reply['value'] as Map<String, Object?>)['code'] as String?;

Object? committedValue(Map<String, Object?> reply) =>
    ((reply['value'] as Map<String, Object?>)['value']);

RustSimulatedHost host({
  Set<String> permissions = const {'archivos_lectura', 'archivos_escritura'},
  Map<String, List<int>> files = const {
    'a': [104, 111, 108, 97],
    'bad': [255],
  },
}) => RustSimulatedHost(
  SimulatedCapabilities(
    permissions: permissions,
    files: files,
    arguments: const ['uno', 'dos'],
    clockStartNanos: 100,
  ),
);

Map<String, Object?> openRoot(RustSimulatedHost simulated) => simulated.reply(
  request(
    'request_directory',
    arguments: [text('root')],
    result: capability(0),
  ),
);

Map<String, Object?> openNetwork(RustSimulatedHost simulated) =>
    simulated.reply(
      request('request_network', result: capability(0, rights: 4, kind: 7)),
    );

Map<String, Object?> openFile(
  RustSimulatedHost simulated,
  String path,
  String mode,
) => simulated.reply(
  request(
    'file_open',
    receiver: capability(0),
    arguments: [text(path), text(mode)],
    result: capability(1, kind: 3),
  ),
);

void main() {
  group('RustSimulatedHost', () {
    test('declares a detached host with sorted permissions', () {
      expect(host().hostDocument(), {
        'permissions': ['archivos_escritura', 'archivos_lectura'],
        'detached': true,
        'files': {
          'a': [104, 111, 108, 97],
          'bad': [255],
        },
        'args': ['uno', 'dos'],
        'clock': [100],
      });
    });

    test('reads a text file through directory and file capabilities', () {
      final simulated = host();
      openRoot(simulated);
      expect(openFile(simulated, 'a', 'lectura')['outcome'], 'committed');
      final read = simulated.reply(
        request('file_read_text', receiver: capability(1, kind: 3)),
      );
      expect(committedValue(read), 'hola');
    });

    test('writes replace the content of a file', () {
      final simulated = host();
      openRoot(simulated);
      openFile(simulated, 'nuevo', 'escritura');
      final written = simulated.reply(
        request(
          'file_write_text',
          receiver: capability(1, kind: 3),
          arguments: [text('contenido')],
        ),
      );
      expect(committedValue(written), 9);
    });

    test('reports invalid utf8 and missing files', () {
      final simulated = host();
      openRoot(simulated);
      openFile(simulated, 'bad', 'lectura');
      final invalid = simulated.reply(
        request('file_read_text', receiver: capability(1, kind: 3)),
      );
      expect(failureCode(invalid), 'utf8_invalido');
      expect(
        failureCode(openFile(simulated, 'falta', 'lectura')),
        'no_encontrado',
      );
    });

    test('rejects escapes, absolute paths and amplification', () {
      final simulated = host();
      openRoot(simulated);
      for (final path in ['../a', '/a', 'a/../b', '']) {
        expect(
          failureCode(openFile(simulated, path, 'lectura')),
          'ruta_invalida',
        );
      }
      final reader = host(
        files: const {
          'a': [1],
        },
      );
      reader.reply(
        request(
          'request_directory',
          arguments: [text('root')],
          result: capability(0, rights: 1),
        ),
      );
      final amplified = reader.reply(
        request(
          'file_open',
          receiver: capability(0, rights: 1),
          arguments: [text('a'), text('escritura')],
          result: capability(2, kind: 3),
        ),
      );
      expect(failureCode(amplified), 'permiso_denegado');
    });

    test('closing a capability invalidates later use', () {
      final simulated = host();
      openRoot(simulated);
      openFile(simulated, 'a', 'lectura');
      final file = capability(1, kind: 3);
      expect(
        simulated.reply(request('file_close', receiver: file))['outcome'],
        'committed',
      );
      final after = simulated.reply(request('file_read_text', receiver: file));
      expect(failureCode(after), 'capacidad_cerrada');
      expect(simulated.openResources, 1);
    });

    test('serves arguments, clock and timer', () {
      final simulated = host(permissions: const {'reloj', 'argumentos'});
      expect(committedValue(simulated.reply(request('arguments_values'))), [
        'uno',
        'dos',
      ]);
      expect(committedValue(simulated.reply(request('clock_now'))), 100);
      final waited = simulated.reply(
        request(
          'timer_wait',
          arguments: [
            {'kind': 'integer', 'value': 50},
          ],
        ),
      );
      expect(committedValue(waited), 150);
    });

    test('unknown operations are interrupted', () {
      final simulated = host();
      final reply = simulated.reply(
        request('desconocida', receiver: capability(9)),
      );
      expect(failureCode(reply), 'capacidad_cerrada');
    });

    test('copies scenario data before serving an execution', () {
      final permissions = {'archivos_lectura'};
      final contents = <int>[104, 111, 108, 97];
      final files = <String, List<int>>{'a': contents};
      final simulated = RustSimulatedHost(
        SimulatedCapabilities(permissions: permissions, files: files),
      );
      permissions.clear();
      contents[0] = 0;
      files.clear();

      openRoot(simulated);
      openFile(simulated, 'a', 'read');
      final reply = simulated.reply(
        request('file_read_text', receiver: capability(1, kind: 3)),
      );
      expect(committedValue(reply), 'hola');
    });

    test('caps directory rights to the configured file permissions', () {
      final simulated = host(permissions: const {'archivos_lectura'});
      final root = simulated.reply(
        request('request_directory', result: capability(0, rights: 3)),
      );
      expect(root['outcome'], 'committed');
      expect(
        failureCode(openFile(simulated, 'a', 'write')),
        'permiso_denegado',
      );
    });

    test('uses only the prepared HTTP response for the granted origin', () {
      final simulated = RustSimulatedHost(
        SimulatedScenario.preparedHttp.capabilities,
      );
      final requestNetwork = openNetwork(simulated);
      expect(requestNetwork['outcome'], 'committed');
      final response = simulated.reply(
        request(
          'network_send',
          receiver: capability(0, rights: 4, kind: 7),
          arguments: [
            {
              'kind': 'http_request',
              'value': {
                'method': 'GET',
                'url': 'https://example.test/greeting',
              },
            },
          ],
        ),
      );
      final value = (response['value'] as Map<String, Object?>)['value'];
      expect(response['outcome'], 'committed');
      expect((value as Map<String, Object?>)['body'], [104, 111, 108, 97]);
      expect(simulated.hostDocument()['network_origins'], [
        'https://example.test',
      ]);
    });

    test('rejects a prepared response outside the granted origin', () {
      final simulated = RustSimulatedHost(
        SimulatedScenario.preparedHttp.capabilities,
      );
      expect(openNetwork(simulated)['outcome'], 'committed');
      final response = simulated.reply(
        request(
          'network_send',
          receiver: capability(0, rights: 4, kind: 7),
          arguments: [
            {
              'kind': 'http_request',
              'value': {'method': 'GET', 'url': 'https://other.test/greeting'},
            },
          ],
        ),
      );

      expect(response['outcome'], 'failed');
      expect(failureCode(response), 'destino_denegado');
    });

    test('returns permission denial, timeout and uncertainty as data', () {
      final denied =
          RustSimulatedHost(SimulatedScenario.noPermissions.capabilities).reply(
            request('request_clock', result: capability(0, rights: 4, kind: 4)),
          );
      final timeout = RustSimulatedHost(SimulatedScenario.timeout.capabilities)
          .reply(
            request(
              'timer_wait',
              arguments: [
                {'kind': 'integer', 'value': 1},
              ],
            ),
          );
      final uncertain = RustSimulatedHost(
        SimulatedScenario.uncertainResult.capabilities,
      );
      openNetwork(uncertain);
      final uncertainReply = uncertain.reply(
        request(
          'network_send',
          receiver: capability(0, rights: 4, kind: 7),
          arguments: [
            {
              'kind': 'http_request',
              'value': {'method': 'POST', 'url': 'https://example.test/update'},
            },
          ],
        ),
      );

      expect(denied['outcome'], 'failed');
      expect(failureCode(denied), 'permiso_denegado');
      expect(timeout['outcome'], 'failed');
      expect(failureCode(timeout), 'tiempo_agotado');
      expect(uncertainReply['outcome'], 'uncertain');
      expect(failureCode(uncertainReply), 'interrumpido');
    });

    test('release clears capability handles and a new host starts clean', () {
      final simulated = host();
      openRoot(simulated);
      openFile(simulated, 'a', 'read');
      expect(simulated.openResources, 2);
      simulated.closeAll();
      expect(simulated.openResources, 0);

      final restarted = host();
      expect(restarted.openResources, 0);
      openRoot(restarted);
      openFile(restarted, 'a', 'read');
      expect(restarted.openResources, 2);
    });
  });

  group('delivery order', () {
    PendingEffectRequest pending(int sequence) => PendingEffectRequest(
      effectSeq: sequence,
      capabilityKind: 'timer',
      operation: 'request_timer',
      argumentsSummary: '',
    );

    test('concurrent pending effects are delivered first-in first-out', () {
      final order = RustSimulatedHost.deliveryOrder([
        pending(3),
        pending(1),
        pending(2),
      ]);
      expect(order.map((item) => item.effectSeq), [1, 2, 3]);
    });

    test('an empty pending list stays empty and the input is not mutated', () {
      expect(RustSimulatedHost.deliveryOrder(const []), isEmpty);
      final input = [pending(2), pending(1)];
      RustSimulatedHost.deliveryOrder(input);
      expect(input.first.effectSeq, 2);
    });
  });
}
