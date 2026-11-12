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

  test('only the simulated store sells its own trial, and only the App Store restores', () {
    expect(PurchaseChannel.values.where((channel) => channel.sellsOwnTrial), [PurchaseChannel.simulated]);
    expect(PurchaseChannel.values.where((channel) => channel.restoresPurchases), [PurchaseChannel.appStore]);
    expect(PurchaseChannel.simulated.managesSubscriptions, isFalse);
  });

  test('only Paddle quotes its price at its own checkout', () {
    expect(PurchaseChannel.values.where((channel) => channel.quotesPriceAtCheckout), [PurchaseChannel.paddle]);
  });
}
