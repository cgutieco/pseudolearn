import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/storekit_client.dart';
import 'package:pseudolearn_app/data/credits/storekit_transaction_queue.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import '../../fakes/fake_purchase_ports.dart';

const _monthly = 'pseudolearn.plus.monthly';
const _topUp = 'pseudolearn.plus.topup150';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeStoreKitClient client;
  late StoreKitTransactionQueue queue;

  setUp(() {
    client = FakeStoreKitClient();
    queue = StoreKitTransactionQueue(client: client, accountToken: () => 'user-uuid');
  });

  test('a purchased transaction confirms the purchase in flight with its signed evidence', () async {
    final attempt = queue.track(AgentProduct.monthly, () async => true);
    await _settle();
    client.stream.add([storeTransaction(_monthly, StoreTransactionStatus.pending), storeTransaction(_monthly, StoreTransactionStatus.purchased)]);
    final confirmed = await attempt as PurchaseConfirmed;
    expect(confirmed.receipt.store, 'app_store');
    expect(confirmed.receipt.evidence, 'jws-1000');
    expect(client.completed, isEmpty);
  });

  test('a transaction is finished only when asked, once', () async {
    final attempt = queue.track(AgentProduct.topUp, () async => true);
    await _settle();
    client.stream.add([storeTransaction(_topUp, StoreTransactionStatus.purchased)]);
    final receipt = (await attempt as PurchaseConfirmed).receipt;
    await queue.finish(receipt);
    await queue.finish(receipt);
    expect(client.completed, hasLength(1));
  });

  test('a cancelled or failed purchase settles and finishes the store transaction', () async {
    final cancelled = queue.track(AgentProduct.monthly, () async => true);
    await _settle();
    client.stream.add([storeTransaction(_monthly, StoreTransactionStatus.canceled)]);
    expect(await cancelled, isA<PurchaseCancelled>());
    final failed = queue.track(AgentProduct.monthly, () async => true);
    await _settle();
    client.stream.add([storeTransaction(_monthly, StoreTransactionStatus.error)]);
    expect((await failed as PurchaseRefused).failure, CreditFailure.upstream);
    expect(client.completed, hasLength(2));
  });

  test('a purchase that the store refuses to start is refused at once', () async {
    expect((await queue.track(AgentProduct.topUp, () async => false) as PurchaseRefused).failure, CreditFailure.upstream);
  });

  test('renewals and unfinished transactions arrive as pending receipts', () async {
    final pending = <String>[];
    queue.pendingReceipts().listen((receipt) => pending.add(receipt.transactionId));
    client.stream.add([
      storeTransaction(_monthly, StoreTransactionStatus.purchased, transactionId: '2001'),
      storeTransaction(_topUp, StoreTransactionStatus.restored, transactionId: '3001'),
      storeTransaction('com.other.product', StoreTransactionStatus.purchased, transactionId: '9'),
    ]);
    await _settle();
    expect(pending, ['2001', '3001']);
  });

  test('a transaction for another product does not settle the purchase in flight', () async {
    final pending = <String>[];
    queue.pendingReceipts().listen((receipt) => pending.add(receipt.transactionId));
    final attempt = queue.track(AgentProduct.topUp, () async => true);
    await _settle();
    client.stream.add([storeTransaction(_monthly, StoreTransactionStatus.purchased, transactionId: '2002')]);
    await _settle();
    expect(pending, ['2002']);
    client.stream.add([storeTransaction(_topUp, StoreTransactionStatus.purchased, transactionId: '3002')]);
    expect((await attempt as PurchaseConfirmed).receipt.transactionId, '3002');
  });

  test('restoring asks the store with the account token', () async {
    await queue.restore();
    expect(client.restores, 1);
  });
}
