import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

RustTransport? _transport;
RustEngineServices? _services;

RustTransport get testTransport => _transport ??= openNativeTransport();

RustEngineServices get nativeTestEngine =>
    _services ??= buildRustEngineServices(testTransport);

void closeTestEngine() {
  _transport?.close();
  _transport = null;
  _services = null;
}
