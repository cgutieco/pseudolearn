import 'dart:convert';

import 'rust_transport.dart';

typedef RustSend = String Function(String requestJson);

final class JsonRustTransport implements RustTransport {
  final RustSend _send;
  final void Function() _release;
  bool _closed = false;

  JsonRustTransport({required RustSend send, required void Function() release})
    : _send = send,
      _release = release;

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    if (_closed) {
      throw const RustBridgeFailure(family: 'usage', detail: 'closed session');
    }
    final request = jsonEncode({
      'operation': operation,
      'arguments': arguments,
    });
    final decoded = jsonDecode(_send(request));
    if (decoded is! Map<String, Object?>) {
      throw const RustBridgeFailure(
        family: 'internal',
        detail: 'malformed response',
      );
    }
    final failure = decoded['failure'];
    if (failure is Map<String, Object?>) {
      throw RustBridgeFailure(
        family: '${failure['family']}',
        detail: '${failure['detail']}',
      );
    }
    return decoded['value'];
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _release();
  }
}
