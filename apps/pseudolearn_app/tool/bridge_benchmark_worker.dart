import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

import 'bridge_benchmark_campaign.dart';

Future<void> main() async {
  try {
    await initializeNativeBridge();
    final configuration =
        jsonDecode(await stdin.transform(utf8.decoder).join())
            as Map<String, Object?>;
    await runBridgeCampaign(
      configuration,
      openNativeTransport,
      (row) => stdout.writeln(jsonEncode(row)),
    );
  } on Object catch (error) {
    stderr.writeln('Bridge worker failed: $error');
    exitCode = 1;
  }
}
