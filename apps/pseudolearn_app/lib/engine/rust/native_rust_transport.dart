import '../bridge/api.dart';
import '../bridge/frb_generated.dart';
import 'json_rust_transport.dart';
import 'rust_transport.dart';

Future<void>? _initializing;

Future<void> initializeNativeBridge() async {
  if (RustLib.instance.initialized) return;
  try {
    await (_initializing ??= RustLib.init());
  } finally {
    _initializing = null;
  }
}

RustTransport openNativeTransport() {
  final session = createSession();
  return JsonRustTransport(
    send: (request) =>
        callSession(sessionIdentifier: session, requestJson: request),
    release: () => closeSession(sessionIdentifier: session),
  );
}
