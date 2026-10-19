import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';

Future<void> main(List<String> arguments) async {
  await build(arguments, (buildInput, buildOutput) async {
    await const FlutterRustBridgeNativeAssetsBuilder(
      cratePath: 'native',
      assetName: 'lib/engine/bridge/frb_generated.io.dart',
    ).run(input: buildInput, output: buildOutput);
  });
}
