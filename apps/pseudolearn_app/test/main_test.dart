import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/main.dart';

final class _Transport implements RustTransport {
  final bool fail;
  int closures = 0;

  _Transport({this.fail = false});

  @override
  Object? call(String operation, Map<String, Object?> arguments) => null;

  @override
  void close() {
    closures++;
    if (fail) throw StateError('release failed');
  }
}

void main() {
  test('shutdown accepts absent sessions and closes open sessions', () {
    final transport = _Transport();
    closeAppTransport(null);
    closeAppTransport(transport);
    expect(transport.closures, 1);
  });

  test(
    'shutdown reports release failures without escaping startup cleanup',
    () {
      final previous = FlutterError.onError;
      final failures = <FlutterErrorDetails>[];
      FlutterError.onError = failures.add;
      addTearDown(() => FlutterError.onError = previous);
      final transport = _Transport(fail: true);
      expect(() => closeAppTransport(transport), returnsNormally);
      expect(transport.closures, 1);
      expect(failures.single.exception, isA<StateError>());
    },
  );
}
