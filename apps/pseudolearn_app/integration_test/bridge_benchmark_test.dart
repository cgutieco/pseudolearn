import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

import '../tool/bridge_benchmark_campaign.dart';

const int campaignPort = int.fromEnvironment('BRIDGE_CAMPAIGN_PORT');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'bridge campaign measures the native library on the device',
    measureCampaignFromHost,
    timeout: Timeout.none,
  );
}

Future<void> measureCampaignFromHost(WidgetTester tester) async {
  expect(
    campaignPort,
    greaterThan(0),
    reason: 'BRIDGE_CAMPAIGN_PORT is required',
  );
  await tester.pumpWidget(const SizedBox.shrink());
  await initializeNativeBridge();
  final channel = await Socket.connect(
    InternetAddress.loopbackIPv4,
    campaignPort,
  );
  try {
    final received = await readConfigurationLine(channel);
    final configuration = jsonDecode(received) as Map<String, Object?>;
    await runBridgeCampaign(
      configuration,
      openNativeTransport,
      (row) => channel.writeln(jsonEncode(row)),
    );
    await channel.flush();
  } finally {
    await channel.close();
  }
}

Future<String> readConfigurationLine(Socket channel) {
  final received = Completer<String>();
  final buffer = StringBuffer();
  late final StreamSubscription<String> subscription;
  subscription = utf8.decoder
      .bind(channel)
      .listen(
        (chunk) {
          final end = chunk.indexOf('\n');
          buffer.write(end < 0 ? chunk : chunk.substring(0, end));
          if (end < 0 || received.isCompleted) return;
          subscription.pause();
          received.complete(buffer.toString());
        },
        onError: received.completeError,
        onDone: () {
          if (received.isCompleted) return;
          received.completeError(
            StateError('Configuration ended before a newline'),
          );
        },
      );
  return received.future;
}
