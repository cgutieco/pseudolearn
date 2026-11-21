import 'dart:async';
import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/ports/pending_purchases.dart';
import 'store_billing_client.dart';
import 'store_billing_profile.dart';
import 'unfinished_store_transactions.dart';

final class StoreTransactionQueue implements PendingPurchases {
  final StoreBillingClient _client;
  final UnfinishedStoreTransactions _unfinishedTransactions;
  final StoreBillingProfile _profile;
  final String? Function() _accountToken;
  final StreamController<PurchaseReceipt> _pending = StreamController.broadcast();
  final Map<String, StoreTransaction> _unfinished = {};
  StreamSubscription<List<StoreTransaction>>? _subscription;
  Completer<PurchaseAttempt>? _inFlight;
  AgentProduct? _inFlightProduct;

  StoreTransactionQueue({
    required this._client,
    required this._unfinishedTransactions,
    required this._profile,
    required this._accountToken,
  });

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
    if (_listen()) unawaited(_recoverUnfinished());
    return _pending.stream;
  }

  @override
  Future<void> finish(PurchaseReceipt receipt) async {
    final transaction = _unfinished.remove(receipt.transactionId);
    if (transaction != null) await _client.complete(transaction, consumable: receipt.product.consumable);
  }

  @override
  Future<void> restore() async {
    _listen();
    await _client.restore(_accountToken());
  }

  bool _listen() {
    if (_subscription != null) return false;
    _subscription = _client.transactions().listen((batch) => batch.forEach(_onTransaction));
    return true;
  }

  Future<void> _recoverUnfinished() async {
    try {
      (await _unfinishedTransactions.unfinished()).forEach(_onTransaction);
    } on Exception {
      return;
    }
  }

  void _onTransaction(StoreTransaction transaction) {
    final product = _productOf(transaction);
    if (product == null) return;
    if (transaction.status == StoreTransactionStatus.pending) {
      if (_profile.pendingMeansDeferredPayment) _settle(product, const PurchaseAwaitsStorePayment());
      return;
    }
    if (_isUnsuccessful(transaction.status)) {
      unawaited(_client.complete(transaction, consumable: product.consumable));
      _settle(product, _unsuccessful(transaction.status));
      return;
    }
    _onGranted(product, transaction);
  }

  void _onGranted(AgentProduct product, StoreTransaction transaction) {
    final receipt = PurchaseReceipt(
      product: product,
      store: _profile.channel.wireName,
      transactionId: transaction.transactionId,
      evidence: transaction.evidence,
    );
    _unfinished[receipt.transactionId] = transaction;
    if (!_settle(product, PurchaseConfirmed(receipt))) _pending.add(receipt);
  }

  AgentProduct? _productOf(StoreTransaction transaction) {
    if (transaction.productId.isNotEmpty) return AgentProduct.fromStoreId(transaction.productId);
    return _isUnsuccessful(transaction.status) ? _inFlightProduct : null;
  }

  bool _isUnsuccessful(StoreTransactionStatus status) =>
      status == StoreTransactionStatus.canceled || status == StoreTransactionStatus.error;

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
