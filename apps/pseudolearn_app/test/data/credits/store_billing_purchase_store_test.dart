import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/store_billing_client.dart';
import 'package:pseudolearn_app/data/credits/store_billing_profile.dart';
import 'package:pseudolearn_app/data/credits/store_billing_purchase_store.dart';
import 'package:pseudolearn_app/data/credits/store_transaction_queue.dart';
import 'package:pseudolearn_app/data/credits/unfinished_store_transactions.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';
import '../../fakes/fake_purchase_ports.dart';

StoreBillingPurchaseStore _storeFor(
  FakeStoreBillingClient client,
  StoreBillingProfile profile,
  RecordingUrlLauncher launcher, {
  String? accountToken = 'user-uuid',
}) => StoreBillingPurchaseStore(
  client: client,
  queue: StoreTransactionQueue(
    client: client,
    unfinishedTransactions: const StoreRedeliversUnfinishedTransactions(),
    profile: profile,
    accountToken: () => accountToken,
  ),
  profile: profile,
  accountToken: () => accountToken,
  launcher: launcher,
);

void main() {
  late FakeStoreBillingClient client;
  late RecordingUrlLauncher launcher;
  late StoreBillingPurchaseStore store;

  setUp(() {
    client = FakeStoreBillingClient(catalog: {'pseudolearn.nodo.monthly': r'$4.99', 'pseudolearn.nodo.topup150': r'$2.99'});
    launcher = RecordingUrlLauncher();
    store = _storeFor(client, StoreBillingProfile.appStore, launcher);
  });

  test('the plan is bought as a subscription and the top-up as a consumable, tagged with the account', () async {
    final plan = store.purchase(AgentProduct.monthly);
    await Future<void>.delayed(Duration.zero);
    client.stream.add([storeTransaction('pseudolearn.nodo.monthly', StoreTransactionStatus.purchased)]);
    expect(await plan, isA<PurchaseConfirmed>());
    final topUp = store.purchase(AgentProduct.topUp);
    await Future<void>.delayed(Duration.zero);
    client.stream.add([storeTransaction('pseudolearn.nodo.topup150', StoreTransactionStatus.purchased, transactionId: '2')]);
    await topUp;
    expect(client.bought, ['pseudolearn.nodo.monthly:subscription', 'pseudolearn.nodo.topup150:consumable']);
    expect(client.tokens, ['user-uuid', 'user-uuid']);
  });

  test('the own trial is not sold in the App Store', () async {
    expect((await store.purchase(AgentProduct.trial) as PurchaseRefused).failure, CreditFailure.purchasesDisabled);
    expect(client.bought, isEmpty);
  });

  test('prices come from the store and missing products are left out', () async {
    expect(await store.prices(), {AgentProduct.monthly: r'$4.99', AgentProduct.topUp: r'$2.99'});
    final empty = _storeFor(FakeStoreBillingClient(), StoreBillingProfile.appStore, launcher, accountToken: null);
    expect(await empty.prices(), isEmpty);
  });

  test('managing the subscription opens the App Store subscriptions page', () async {
    expect(await store.manageSubscription(), isTrue);
    expect(launcher.opened.single.toString(), 'https://apps.apple.com/account/subscriptions');
    expect(store.channel, PurchaseChannel.appStore);
  });

  test('Google Play sells through its own channel and opens the plan in Play subscriptions', () async {
    final play = _storeFor(client, StoreBillingProfile.googlePlay, launcher);
    expect(play.channel, PurchaseChannel.googlePlay);
    expect(await play.manageSubscription(), isTrue);
    expect(
      launcher.opened.single.toString(),
      'https://play.google.com/store/account/subscriptions?sku=pseudolearn.nodo.monthly&package=com.pseudolearn.app',
    );
  });

  test('a store that cannot start the purchase refuses it', () async {
    final refusing = FakeStoreBillingClient(buyStarts: false);
    final play = _storeFor(refusing, StoreBillingProfile.googlePlay, launcher);
    expect((await play.purchase(AgentProduct.topUp) as PurchaseRefused).failure, CreditFailure.upstream);
  });

  test('a purchase without a signed-in account carries no account token', () async {
    final anonymous = _storeFor(client, StoreBillingProfile.googlePlay, launcher, accountToken: null);
    final attempt = anonymous.purchase(AgentProduct.topUp);
    await Future<void>.delayed(Duration.zero);
    client.stream.add([storeTransaction('pseudolearn.nodo.topup150', StoreTransactionStatus.purchased)]);
    await attempt;
    expect(client.tokens, [null]);
  });

  test('a launcher that cannot open the page reports it', () async {
    final play = _storeFor(client, StoreBillingProfile.googlePlay, RecordingUrlLauncher(result: false));
    expect(await play.manageSubscription(), isFalse);
  });
}
