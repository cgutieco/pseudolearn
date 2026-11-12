import 'package:in_app_purchase/in_app_purchase.dart';
import 'storekit_client.dart';

final class InAppPurchaseStoreKitClient implements StoreKitClient {
  final InAppPurchase _purchases;
  final Map<String, ProductDetails> _products = {};

  InAppPurchaseStoreKitClient({InAppPurchase? purchases}) : _purchases = purchases ?? InAppPurchase.instance;

  static const Map<PurchaseStatus, StoreTransactionStatus> _statuses = {
    PurchaseStatus.pending: StoreTransactionStatus.pending,
    PurchaseStatus.purchased: StoreTransactionStatus.purchased,
    PurchaseStatus.restored: StoreTransactionStatus.restored,
    PurchaseStatus.canceled: StoreTransactionStatus.canceled,
    PurchaseStatus.error: StoreTransactionStatus.error,
  };

  @override
  Stream<List<StoreTransaction>> transactions() => _purchases.purchaseStream.map(
    (details) => [
      for (final detail in details)
        StoreTransaction(
          productId: detail.productID,
          transactionId: detail.purchaseID ?? '',
          evidence: detail.verificationData.serverVerificationData,
          status: _statuses[detail.status] ?? StoreTransactionStatus.error,
          handle: detail,
        ),
    ],
  );

  @override
  Future<Map<String, String>> prices(Set<String> productIds) async {
    if (!await _purchases.isAvailable()) return const {};
    final response = await _purchases.queryProductDetails(productIds);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
    return {for (final product in response.productDetails) product.id: product.price};
  }

  @override
  Future<bool> buy(String productId, {required bool consumable, required String? accountToken}) async {
    final product = _products[productId] ?? (await _query(productId));
    if (product == null) return false;
    final parameters = PurchaseParam(productDetails: product, applicationUserName: accountToken);
    return consumable
        ? _purchases.buyConsumable(purchaseParam: parameters)
        : _purchases.buyNonConsumable(purchaseParam: parameters);
  }

  @override
  Future<void> complete(StoreTransaction transaction) async {
    final details = transaction.handle;
    if (details is PurchaseDetails && details.pendingCompletePurchase) {
      await _purchases.completePurchase(details);
    }
  }

  @override
  Future<void> restore(String? accountToken) => _purchases.restorePurchases(applicationUserName: accountToken);

  Future<ProductDetails?> _query(String productId) async {
    await prices({productId});
    return _products[productId];
  }
}
