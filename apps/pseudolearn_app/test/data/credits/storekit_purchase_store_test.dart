import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/storekit_client.dart';
import 'package:pseudolearn_app/data/credits/storekit_purchase_store.dart';
import 'package:pseudolearn_app/data/credits/storekit_transaction_queue.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';
import '../../fakes/fake_purchase_ports.dart';

void main() {
  late FakeStoreKitClient client;
  late RecordingUrlLauncher launcher;
  late StoreKitPurchaseStore store;

  setUp(() {
    client = FakeStoreKitClient(catalog: {'pseudolearn.plus.monthly': r'$4.99', 'pseudolearn.plus.topup150': r'$2.99'});
    launcher = RecordingUrlLauncher();
    store = StoreKitPurchaseStore(
      client: client,
      queue: StoreKitTransactionQueue(client: client, accountToken: () => 'user-uuid'),
      accountToken: () => 'user-uuid',
      launcher: launcher,
    );
  });

  test('the plan is bought as a subscription and the top-up as a consumable, tagged with the account', () async {
    final plan = store.purchase(AgentProduct.monthly);
    await Future<void>.delayed(Duration.zero);
    client.stream.add([storeTransaction('pseudolearn.plus.monthly', StoreTransactionStatus.purchased)]);
    expect(await plan, isA<PurchaseConfirmed>());
    final topUp = store.purchase(AgentProduct.topUp);
    await Future<void>.delayed(Duration.zero);
    client.stream.add([storeTransaction('pseudolearn.plus.topup150', StoreTransactionStatus.purchased, transactionId: '2')]);
    await topUp;
    expect(client.bought, ['pseudolearn.plus.monthly:subscription', 'pseudolearn.plus.topup150:consumable']);
    expect(client.tokens, ['user-uuid', 'user-uuid']);
  });

  test('the own trial is not sold in the App Store', () async {
    expect((await store.purchase(AgentProduct.trial) as PurchaseRefused).failure, CreditFailure.purchasesDisabled);
    expect(client.bought, isEmpty);
  });

  test('prices come from the store and missing products are left out', () async {
    expect(await store.prices(), {AgentProduct.monthly: r'$4.99', AgentProduct.topUp: r'$2.99'});
    final empty = StoreKitPurchaseStore(
      client: FakeStoreKitClient(),
      queue: StoreKitTransactionQueue(client: client, accountToken: () => null),
      accountToken: () => null,
      launcher: launcher,
    );
    expect(await empty.prices(), isEmpty);
  });

  test('managing the subscription opens the App Store subscriptions page', () async {
    expect(await store.manageSubscription(), isTrue);
    expect(launcher.opened.single.toString(), 'https://apps.apple.com/account/subscriptions');
    expect(store.channel, PurchaseChannel.appStore);
  });
}
