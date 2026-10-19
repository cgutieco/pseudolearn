import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:pseudolearn_app/engine/bridge/api.dart';
import 'package:pseudolearn_app/engine/bridge/frb_generated.dart';

void main() {
  setUpAll(() async {
    await RustLib.init(
      externalLibrary: ExternalLibrary.open(_nativeLibraryPath()),
    );
  });

  test('native transport owns values across calls and closes its session', () {
    final session = createSession();
    final version =
        jsonDecode(
              callSession(
                sessionIdentifier: session,
                requestJson: jsonEncode({
                  'operation': 'version',
                  'arguments': <String, Object?>{},
                }),
              ),
            )
            as Map<String, dynamic>;
    expect(version['value']['capabilities'], contains('execute'));
    final malformed =
        jsonDecode(callSession(sessionIdentifier: session, requestJson: '{'))
            as Map<String, dynamic>;
    expect(malformed['failure']['family'], 'usage');
    expect(() => closeSession(sessionIdentifier: session), returnsNormally);
    expect(
      callSession(
        sessionIdentifier: session,
        requestJson: jsonEncode({
          'operation': 'version',
          'arguments': <String, Object?>{},
        }),
      ),
      contains('invalid session'),
    );
  });
}

String _nativeLibraryPath() {
  if (Platform.isMacOS) {
    return 'native/target/debug/libpseudolearn_bridge.dylib';
  }
  if (Platform.isWindows) {
    return 'native/target/debug/pseudolearn_bridge.dll';
  }
  return 'native/target/debug/libpseudolearn_bridge.so';
}
