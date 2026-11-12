import 'dart:async';
import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/model/credits/purchase_channel.dart';
import '../../domain/ports/pending_purchases.dart';
import 'storekit_client.dart';

final class StoreKitTransactionQueue implements PendingPurchases {
  final StoreKitClient _client;
  final String? Function() _accountToken;
  final StreamController<PurchaseReceipt> _pending = StreamController.broadcast();
  final Map<String, StoreTransaction> _unfinished = {};
  StreamSubscription<List<StoreTransaction>>? _subscription;
  Completer<PurchaseAttempt>? _inFlight;
  AgentProduct? _inFlightProduct;

  StoreKitTransactionQueue({required this._client, required this._accountToken});

  Future<PurchaseAttempt> track(AgentProduct product, Future<bool> Function() start) async {
    _listen();
    final attempt = Completer<PurchaseAttempt>();
    _inFlight = attempt;
    _inFlightProduct = product;
    if (!await start()) _settle(product, const PurchaseRefused(CreditFailure.upstream));
    return attempt.future;
  }

  @override
  Stream<PurchaseReceipt> pendingReceipts() {
    _listen();
    return _pending.stream;
  }

  @override
  Future<void> finish(PurchaseReceipt receipt) async {
    final transaction = _unfinished.remove(receipt.transactionId);
    if (transaction != null) await _client.complete(transaction);
  }

  @override
  Future<void> restore() async {
    _listen();
    await _client.restore(_accountToken());
  }

  void _listen() {
    _subscription ??= _client.transactions().listen((batch) => batch.forEach(_onTransaction));
  }

  void _onTransaction(StoreTransaction transaction) {
    final product = AgentProduct.fromStoreId(transaction.productId);
    if (product == null || transaction.status == StoreTransactionStatus.pending) return;
    if (transaction.status == StoreTransactionStatus.canceled || transaction.status == StoreTransactionStatus.error) {
      unawaited(_client.complete(transaction));
      _settle(product, _unsuccessful(transaction.status));
      return;
    }
    final receipt = PurchaseReceipt(
      product: product,
      store: PurchaseChannel.appStore.wireName,
      transactionId: transaction.transactionId,
      evidence: transaction.evidence,
    );
    _unfinished[receipt.transactionId] = transaction;
    if (!_settle(product, PurchaseConfirmed(receipt))) _pending.add(receipt);
  }

  PurchaseAttempt _unsuccessful(StoreTransactionStatus status) => status == StoreTransactionStatus.canceled
      ? const PurchaseCancelled()
      : const PurchaseRefused(CreditFailure.upstream);

  bool _settle(AgentProduct product, PurchaseAttempt attempt) {
    final inFlight = _inFlight;
    if (inFlight == null || _inFlightProduct != product || inFlight.isCompleted) return false;
    _inFlight = null;
    _inFlightProduct = null;
    inFlight.complete(attempt);
    return true;
  }
}
