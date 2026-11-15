import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

final class RecordingRustTransport implements RustTransport {
  final RustTransport _inner;
  final List<String> operations = [];

  RecordingRustTransport(this._inner);

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    operations.add(operation);
    return _inner.call(operation, arguments);
  }

  @override
  void close() {}
}
