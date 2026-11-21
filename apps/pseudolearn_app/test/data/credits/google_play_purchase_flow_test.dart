import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:pseudolearn_app/data/credits/google_play_purchase_flow.dart';
import 'package:pseudolearn_app/data/credits/store_billing_client.dart';
import '../../fakes/fake_in_app_purchase.dart';

const _monthly = 'pseudolearn.nodo.monthly';
const _topUp = 'pseudolearn.nodo.topup150';

void main() {
  late FakeInAppPurchase purchases;

  GooglePlayPurchaseFlow flowWith(FakeAndroidBilling billing) =>
      GooglePlayPurchaseFlow(purchases: purchases, billing: billing);

  setUp(() => purchases = FakeInAppPurchase());

  test('consumables are never consumed by the store on purchase', () {
    expect(flowWith(FakeAndroidBilling()).consumesWhenPurchased, isFalse);
  });

  test('only the base plan of a subscription is sold, never its discounted offers', () {
    final flow = flowWith(FakeAndroidBilling());
    final offers = playSubscription(_monthly, ['intro-offer', null, 'winback']);
    expect(offers.where(flow.sells).map((offer) => offer.offerToken), ['offer-token-1']);
  });

  test('one-time products and foreign product details are sold', () {
    final flow = flowWith(FakeAndroidBilling());
    expect(flow.sells(playOneTime(_topUp, r'$2.99')), isTrue);
    expect(
      flow.sells(ProductDetails(id: _topUp, title: '', description: '', price: '', rawPrice: 0, currencyCode: 'USD')),
      isTrue,
    );
  });

  test('a granted top-up is consumed and never just acknowledged', () async {
    final billing = FakeAndroidBilling();
    final purchase = playPurchase(_topUp);
    await flowWith(billing).complete(purchase, consumable: true);
    expect(billing.consumed, [purchase]);
    expect(purchases.completed, isEmpty);
  });

  test('a granted subscription is acknowledged once', () async {
    final billing = FakeAndroidBilling();
    final purchase = playPurchase(_monthly);
    await flowWith(billing).complete(purchase, consumable: false);
    await flowWith(billing).complete(playPurchase(_monthly, acknowledged: true), consumable: false);
    expect(purchases.completed, [purchase]);
    expect(billing.consumed, isEmpty);
  });

  test('pending, cancelled or failed purchases are neither acknowledged nor consumed', () async {
    final billing = FakeAndroidBilling();
    final flow = flowWith(billing);
    await flow.complete(playPurchase(_topUp, state: PurchaseStateWrapper.pending), consumable: true);
    await flow.complete(playPurchase(_monthly)..status = PurchaseStatus.canceled, consumable: false);
    await flow.complete(playPurchase(_monthly)..status = PurchaseStatus.error, consumable: false);
    expect(billing.consumed, isEmpty);
    expect(purchases.completed, isEmpty);
  });

  test('a restored purchase is completed like a new one', () async {
    final billing = FakeAndroidBilling();
    final purchase = playPurchase(_monthly)..status = PurchaseStatus.restored;
    await flowWith(billing).complete(purchase, consumable: false);
    expect(purchases.completed, [purchase]);
  });

  test('unfinished purchases are unacknowledged plans and unconsumed top-ups', () async {
    final billing = FakeAndroidBilling(past: [
      playPurchase(_monthly, orderId: 'GPA.unacknowledged', token: 't1'),
      playPurchase(_monthly, orderId: 'GPA.acknowledged', token: 't2', acknowledged: true),
      playPurchase(_topUp, orderId: 'GPA.top-up', token: 't3', acknowledged: true),
      playPurchase(_topUp, orderId: '', token: 't4', state: PurchaseStateWrapper.pending),
      playPurchase('com.other.product', orderId: 'GPA.other', token: 't5', acknowledged: true),
    ]);
    final unfinished = await flowWith(billing).unfinished();
    expect(unfinished.map((transaction) => transaction.transactionId), ['GPA.unacknowledged', 'GPA.top-up']);
    expect(unfinished.map((transaction) => transaction.status), everyElement(StoreTransactionStatus.purchased));
  });

  test('no past purchases means nothing unfinished', () async {
    expect(await flowWith(FakeAndroidBilling()).unfinished(), isEmpty);
  });
}
