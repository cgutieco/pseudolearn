import 'dart:async';
import 'package:pseudolearn_app/data/credits/storekit_client.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/checkout_link.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_attempt.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';
import 'package:pseudolearn_app/domain/ports/checkout_gateway.dart';
import 'package:pseudolearn_app/domain/ports/external_url_launcher.dart';
import 'package:pseudolearn_app/domain/ports/pending_purchases.dart';
import 'package:pseudolearn_app/domain/ports/purchase_store.dart';

final class RecordingUrlLauncher implements ExternalUrlLauncher {
  final List<Uri> opened = [];
  bool result;

  RecordingUrlLauncher({this.result = true});

  @override
  Future<bool> launchExternalUrl(Uri url) async {
    opened.add(url);
    return result;
  }
}

final class ScriptedPurchaseStore implements PurchaseStore {
  @override
  final PurchaseChannel channel;
  PurchaseAttempt attempt;
  final Map<AgentProduct, String> knownPrices;
  int managed = 0;

  ScriptedPurchaseStore({
    this.channel = PurchaseChannel.appStore,
    this.attempt = const PurchaseCancelled(),
    this.knownPrices = const {},
  });

  @override
  Future<PurchaseAttempt> purchase(AgentProduct product) async => attempt;

  @override
  Future<Map<AgentProduct, String>> prices() async => knownPrices;

  @override
  Future<bool> manageSubscription() async {
    managed++;
    return true;
  }
}

final class FakePendingPurchases implements PendingPurchases {
  final StreamController<PurchaseReceipt> receipts = StreamController.broadcast();
  final List<PurchaseReceipt> finished = [];
  int restored = 0;

  @override
  Stream<PurchaseReceipt> pendingReceipts() => receipts.stream;

  @override
  Future<void> finish(PurchaseReceipt receipt) async => finished.add(receipt);

  @override
  Future<void> restore() async => restored++;
}

final class FakeCheckoutGateway implements CheckoutGateway {
  CheckoutLink checkoutLink;
  CheckoutLink portalLink;
  final List<AgentProduct> requested = [];

  FakeCheckoutGateway({
    this.checkoutLink = const CheckoutLinkRefused(CreditFailure.upstream),
    this.portalLink = const CheckoutLinkRefused(CreditFailure.upstream),
  });

  @override
  Future<CheckoutLink> checkout(AgentProduct product) async {
    requested.add(product);
    return checkoutLink;
  }

  @override
  Future<CheckoutLink> portal() async => portalLink;
}

final class FakeStoreKitClient implements StoreKitClient {
  final StreamController<List<StoreTransaction>> stream = StreamController.broadcast();
  final List<String> bought = [];
  final List<String?> tokens = [];
  final List<StoreTransaction> completed = [];
  final Map<String, String> catalog;
  bool buyStarts;
  int restores = 0;

  FakeStoreKitClient({this.catalog = const {}, this.buyStarts = true});

  @override
  Stream<List<StoreTransaction>> transactions() => stream.stream;

  @override
  Future<Map<String, String>> prices(Set<String> productIds) async =>
      {for (final id in productIds) if (catalog[id] != null) id: catalog[id]!};

  @override
  Future<bool> buy(String productId, {required bool consumable, required String? accountToken}) async {
    bought.add('$productId:${consumable ? 'consumable' : 'subscription'}');
    tokens.add(accountToken);
    return buyStarts;
  }

  @override
  Future<void> complete(StoreTransaction transaction) async => completed.add(transaction);

  @override
  Future<void> restore(String? accountToken) async => restores++;
}

StoreTransaction storeTransaction(
  String productId,
  StoreTransactionStatus status, {
  String transactionId = '1000',
}) => StoreTransaction(
  productId: productId,
  transactionId: transactionId,
  evidence: 'jws-$transactionId',
  status: status,
  handle: transactionId,
);
