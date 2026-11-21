import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/store_billing_client.dart';
import 'package:pseudolearn_app/data/credits/store_billing_profile.dart';
import 'package:pseudolearn_app/data/credits/store_transaction_queue.dart';
import 'package:pseudolearn_app/data/credits/unfinished_store_transactions.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import '../../fakes/fake_purchase_ports.dart';

const _monthly = 'pseudolearn.nodo.monthly';
const _topUp = 'pseudolearn.nodo.topup150';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeStoreBillingClient client;
  late StoreTransactionQueue queue;

  setUp(() {
    client = FakeStoreBillingClient();
    queue = StoreTransactionQueue(
      client: client,
      unfinishedTransactions: const StoreRedeliversUnfinishedTransactions(),
      profile: StoreBillingProfile.appStore,
      accountToken: () => 'user-uuid',
    );
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

  group('on Google Play', () {
    late ScriptedUnfinishedTransactions unfinished;

    StoreTransactionQueue playQueue() => StoreTransactionQueue(
      client: client,
      unfinishedTransactions: unfinished,
      profile: StoreBillingProfile.googlePlay,
      accountToken: () => 'user-uuid',
    );

    setUp(() => unfinished = ScriptedUnfinishedTransactions());

    test('receipts carry the google_play store name', () async {
      final queue = playQueue();
      final attempt = queue.track(AgentProduct.monthly, () async => true);
      await _settle();
      client.stream.add([storeTransaction(_monthly, StoreTransactionStatus.purchased)]);
      expect((await attempt as PurchaseConfirmed).receipt.store, 'google_play');
    });

    test('a deferred payment settles the purchase as awaiting the store and grants nothing', () async {
      final queue = playQueue();
      final pending = <String>[];
      queue.pendingReceipts().listen((receipt) => pending.add(receipt.transactionId));
      final attempt = queue.track(AgentProduct.topUp, () async => true);
      await _settle();
      client.stream.add([storeTransaction(_topUp, StoreTransactionStatus.pending, transactionId: '4001')]);
      expect(await attempt, isA<PurchaseAwaitsStorePayment>());
      expect(pending, isEmpty);
      client.stream.add([storeTransaction(_topUp, StoreTransactionStatus.purchased, transactionId: '4001')]);
      await _settle();
      expect(pending, ['4001']);
    });

    test('a cancellation without a product settles the purchase in flight', () async {
      final queue = playQueue();
      final attempt = queue.track(AgentProduct.monthly, () async => true);
      await _settle();
      client.stream.add([storeTransaction('', StoreTransactionStatus.canceled)]);
      expect(await attempt, isA<PurchaseCancelled>());
    });

    test('an error without a product refuses the purchase in flight', () async {
      final queue = playQueue();
      final attempt = queue.track(AgentProduct.topUp, () async => true);
      await _settle();
      client.stream.add([storeTransaction('', StoreTransactionStatus.error)]);
      expect((await attempt as PurchaseRefused).failure, CreditFailure.upstream);
    });

    test('a granted transaction without a product is ignored', () async {
      final queue = playQueue();
      final pending = <String>[];
      queue.pendingReceipts().listen((receipt) => pending.add(receipt.transactionId));
      client.stream.add([storeTransaction('', StoreTransactionStatus.purchased)]);
      await _settle();
      expect(pending, isEmpty);
    });

    test('a product-less cancellation with nothing in flight is ignored', () async {
      playQueue().pendingReceipts();
      client.stream.add([storeTransaction('', StoreTransactionStatus.canceled)]);
      await _settle();
      expect(client.completed, isEmpty);
    });

    test('purchases left unfinished by a previous launch are redeemed once', () async {
      unfinished = ScriptedUnfinishedTransactions(transactions: [
        storeTransaction(_topUp, StoreTransactionStatus.purchased, transactionId: '5001'),
        storeTransaction(_monthly, StoreTransactionStatus.purchased, transactionId: '5002'),
      ]);
      final queue = playQueue();
      final pending = <String>[];
      queue.pendingReceipts().listen((receipt) => pending.add(receipt.transactionId));
      queue.pendingReceipts();
      await _settle();
      expect(pending, ['5001', '5002']);
      expect(unfinished.queries, 1);
    });

    test('a failing recovery leaves the queue working', () async {
      unfinished = ScriptedUnfinishedTransactions(fails: true);
      final queue = playQueue();
      queue.pendingReceipts();
      await _settle();
      final attempt = queue.track(AgentProduct.monthly, () async => true);
      await _settle();
      client.stream.add([storeTransaction(_monthly, StoreTransactionStatus.purchased)]);
      expect(await attempt, isA<PurchaseConfirmed>());
    });

    test('finishing tells the store whether the product is consumed', () async {
      final queue = playQueue();
      final pending = <PurchaseReceipt>[];
      queue.pendingReceipts().listen(pending.add);
      client.stream.add([
        storeTransaction(_topUp, StoreTransactionStatus.purchased, transactionId: '6001'),
        storeTransaction(_monthly, StoreTransactionStatus.purchased, transactionId: '6002'),
      ]);
      await _settle();
      for (final receipt in pending) {
        await queue.finish(receipt);
      }
      expect(client.completedAsConsumable, [true, false]);
    });
  });

  test('the App Store keeps waiting while a transaction is pending', () async {
    final attempt = queue.track(AgentProduct.monthly, () async => true);
    var settled = false;
    unawaited(attempt.then((_) => settled = true));
    await _settle();
    client.stream.add([storeTransaction(_monthly, StoreTransactionStatus.pending)]);
    await _settle();
    expect(settled, isFalse);
  });
}
