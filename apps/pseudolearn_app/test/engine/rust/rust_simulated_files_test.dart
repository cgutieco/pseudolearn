import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_simulated_files.dart';

Map<String, Object?> _capability(int slot, int rights) => {
  'slot': slot,
  'generation': 1,
  'rights': rights,
  'kind': 2,
};

SimulatedHostRequest _request(
  String operation, {
  Map<String, Object?>? receiver,
  List<Map<String, Object?>> arguments = const [],
  Map<String, Object?>? result,
}) => SimulatedHostRequest({
  'operation': operation,
  'receiver': receiver,
  'arguments': arguments,
  'result_capability': result,
});

void main() {
  group('RustSimulatedFiles', () {
    test('reads only data stored in its virtual file map', () {
      final files = RustSimulatedFiles({
        'datos.txt': [104, 111, 108, 97],
      });
      files.register(_capability(0, 1), '', 1);
      files.reply(
        _request(
          'file_open',
          receiver: _capability(0, 1),
          arguments: [
            {'kind': 'text', 'value': 'datos.txt'},
            {'kind': 'text', 'value': 'read'},
          ],
          result: _capability(1, 1),
        ),
      );

      final reply = files.reply(
        _request('file_read_text', receiver: _capability(1, 1)),
      );

      expect((reply['value'] as Map<String, Object?>)['value'], 'hola');
    });

    test('rejects traversal and cannot amplify directory rights', () {
      final files = RustSimulatedFiles({
        'secret.txt': [120],
      });
      files.register(_capability(0, 1), '', 1);
      expect(
        () => files.reply(
          _request(
            'file_open',
            receiver: _capability(0, 1),
            arguments: [
              {'kind': 'text', 'value': '../secret.txt'},
              {'kind': 'text', 'value': 'read'},
            ],
            result: _capability(1, 3),
          ),
        ),
        throwsA(isA<RustSimulatedHostFailure>()),
      );
      expect(files.openResources, 1);
    });
  });
}
