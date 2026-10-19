import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/json_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

void main() {
  JsonRustTransport build(
    String Function(String) send, [
    void Function()? release,
  ]) => JsonRustTransport(send: send, release: release ?? () {});

  group('JsonRustTransport', () {
    test('wraps the operation and returns the value', () {
      late String request;
      final transport = build((json) {
        request = json;
        return jsonEncode({'value': 7});
      });
      expect(transport.call('version', {'a': 1}), 7);
      expect(jsonDecode(request), {
        'operation': 'version',
        'arguments': {'a': 1},
      });
    });

    test('maps a failure to a typed exception', () {
      final transport = build(
        (_) => jsonEncode({
          'failure': {'family': 'usage', 'detail': 'bad'},
        }),
      );
      expect(
        () => transport.call('x', {}),
        throwsA(
          isA<RustBridgeFailure>()
              .having((f) => f.isUsage, 'isUsage', true)
              .having((f) => f.detail, 'detail', 'bad'),
        ),
      );
    });

    test('rejects a malformed response', () {
      final transport = build((_) => '[]');
      expect(
        () => transport.call('x', {}),
        throwsA(
          isA<RustBridgeFailure>().having(
            (f) => f.family,
            'family',
            'internal',
          ),
        ),
      );
    });

    test('closes once and rejects calls afterwards', () {
      var releases = 0;
      final transport = build((_) => '{}', () => releases++);
      transport.close();
      transport.close();
      expect(releases, 1);
      expect(() => transport.call('x', {}), throwsA(isA<RustBridgeFailure>()));
    });
  });
}
