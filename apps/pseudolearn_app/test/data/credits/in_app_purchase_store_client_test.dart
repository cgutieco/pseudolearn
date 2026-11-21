import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pseudolearn_app/data/credits/app_store_purchase_flow.dart';
import 'package:pseudolearn_app/data/credits/google_play_purchase_flow.dart';
import 'package:pseudolearn_app/data/credits/in_app_purchase_store_client.dart';
import 'package:pseudolearn_app/data/credits/store_billing_client.dart';
import '../../fakes/fake_in_app_purchase.dart';

const _monthly = 'pseudolearn.nodo.monthly';
const _topUp = 'pseudolearn.nodo.topup150';

void main() {
  InAppPurchaseStoreClient playClient(FakeInAppPurchase purchases, [FakeAndroidBilling? billing]) =>
      InAppPurchaseStoreClient(
        purchases: purchases,
        flow: GooglePlayPurchaseFlow(purchases: purchases, billing: billing ?? FakeAndroidBilling()),
      );

  test('prices show the base plan of the subscription and the top-up', () async {
    final purchases = FakeInAppPurchase(catalog: [
      ...playSubscription(_monthly, ['intro-offer', null]),
      playOneTime(_topUp, r'$2.99'),
    ]);
    expect(await playClient(purchases).prices({_monthly, _topUp}), {_monthly: r'$4.99', _topUp: r'$2.99'});
  });

  test('an unavailable store has no prices and nothing to sell', () async {
    final purchases = FakeInAppPurchase(catalog: [playOneTime(_topUp, r'$2.99')], available: false);
    final client = playClient(purchases);
    expect(await client.prices({_topUp}), isEmpty);
    expect(await client.buy(_topUp, consumable: true, accountToken: 'user-uuid'), isFalse);
    expect(purchases.bought, isEmpty);
  });

  test('an unknown product cannot be bought', () async {
    expect(await playClient(FakeInAppPurchase()).buy('missing', consumable: false, accountToken: null), isFalse);
  });

  test('Google Play buys the top-up without consuming it and tags the account', () async {
    final purchases = FakeInAppPurchase(catalog: [playOneTime(_topUp, r'$2.99')]);
    expect(await playClient(purchases).buy(_topUp, consumable: true, accountToken: 'user-uuid'), isTrue);
    expect(purchases.autoConsumed, [false]);
    expect(purchases.userNames, ['user-uuid']);
  });

  test('the App Store buys the top-up as an automatically consumed product', () async {
    final purchases = FakeInAppPurchase(catalog: [playOneTime(_topUp, r'$2.99')]);
    final client = InAppPurchaseStoreClient(purchases: purchases, flow: AppStorePurchaseFlow(purchases));
    await client.buy(_topUp, consumable: true, accountToken: null);
    await client.buy(_topUp, consumable: false, accountToken: null);
    expect(purchases.autoConsumed, [true]);
    expect(purchases.bought, [_topUp, _topUp]);
  });

  test('store updates become transactions and completion goes through the flow', () async {
    final purchases = FakeInAppPurchase();
    final billing = FakeAndroidBilling();
    final client = playClient(purchases, billing);
    final received = client.transactions().first;
    final purchase = playPurchase(_topUp, orderId: 'GPA.9', token: 'token-9');
    purchases.updates.add([purchase]);
    final transaction = (await received).single;
    expect(transaction.transactionId, 'GPA.9');
    expect(transaction.evidence, 'token-9');
    await client.complete(transaction, consumable: true);
    expect(billing.consumed, [purchase]);
  });

  test('a transaction without store details is not completed', () async {
    final purchases = FakeInAppPurchase();
    final billing = FakeAndroidBilling();
    await playClient(purchases, billing).complete(
      const StoreTransaction(productId: _topUp, transactionId: '1', evidence: '', status: StoreTransactionStatus.purchased, handle: '1'),
      consumable: true,
    );
    expect(billing.consumed, isEmpty);
  });

  test('restoring passes the account to the store', () async {
    final purchases = FakeInAppPurchase();
    await playClient(purchases).restore('user-uuid');
    expect(purchases.restoredFor, ['user-uuid']);
  });

  test('a cancelled purchase keeps its status', () async {
    final purchases = FakeInAppPurchase();
    final received = playClient(purchases).transactions().first;
    purchases.updates.add([
      PurchaseDetails(
        productID: '',
        verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: '', source: 'google_play'),
        transactionDate: null,
        status: PurchaseStatus.canceled,
      ),
    ]);
    expect((await received).single.status, StoreTransactionStatus.canceled);
  });
}
