import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

RustTransport? _transport;
RustEngineServices? _services;

RustTransport get contentTransport => _transport ??= openNativeTransport();

RustEngineServices get contentEngine =>
    _services ??= buildRustEngineServices(contentTransport);

void closeContentEngine() {
  _transport?.close();
  _transport = null;
  _services = null;
}
