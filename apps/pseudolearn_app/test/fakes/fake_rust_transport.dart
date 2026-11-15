import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

typedef FakeRustHandler = Object? Function(Map<String, Object?> arguments);

final class FakeRustTransport implements RustTransport {
  final Map<String, FakeRustHandler> handlers;
  final List<String> calls = [];
  bool isClosed = false;

  FakeRustTransport(this.handlers);

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    calls.add(operation);
    final handler = handlers[operation];
    if (handler == null) {
      throw RustBridgeFailure(family: 'usage', detail: 'unscripted $operation');
    }
    return handler(arguments);
  }

  @override
  void close() => isClosed = true;
}
