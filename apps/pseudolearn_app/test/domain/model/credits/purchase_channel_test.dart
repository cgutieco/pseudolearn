import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';

void main() {
  test('each channel round-trips through its wire name', () {
    for (final channel in PurchaseChannel.values) {
      expect(PurchaseChannel.fromWireName(channel.wireName), channel);
    }
  });

  test('unknown or missing wire names have no channel', () {
    expect(PurchaseChannel.fromWireName(null), isNull);
    expect(PurchaseChannel.fromWireName(''), isNull);
    expect(PurchaseChannel.fromWireName('APP_STORE'), isNull);
  });

  test('only the simulated store sells its own trial, and only the platform stores restore', () {
    expect(PurchaseChannel.values.where((channel) => channel.sellsOwnTrial), [PurchaseChannel.simulated]);
    expect(
      PurchaseChannel.values.where((channel) => channel.restoresPurchases),
      [PurchaseChannel.appStore, PurchaseChannel.googlePlay],
    );
    expect(PurchaseChannel.simulated.managesSubscriptions, isFalse);
  });

  test('only the unavailable channel sells nothing', () {
    expect(PurchaseChannel.values.where((channel) => !channel.sells), [PurchaseChannel.unavailable]);
    expect(PurchaseChannel.unavailable.managesSubscriptions, isFalse);
  });

  test('only Paddle quotes its price at its own checkout', () {
    expect(PurchaseChannel.values.where((channel) => channel.quotesPriceAtCheckout), [PurchaseChannel.paddle]);
  });

  test('Google Play uses its own wire name and manages its subscriptions', () {
    expect(PurchaseChannel.fromWireName('google_play'), PurchaseChannel.googlePlay);
    expect(PurchaseChannel.googlePlay.managesSubscriptions, isTrue);
    expect(PurchaseChannel.googlePlay.sellsOwnTrial, isFalse);
  });
}
