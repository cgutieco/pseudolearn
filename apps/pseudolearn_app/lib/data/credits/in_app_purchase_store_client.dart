import 'package:in_app_purchase/in_app_purchase.dart';
import 'platform_purchase_flow.dart';
import 'purchase_details_transaction.dart';
import 'store_billing_client.dart';

final class InAppPurchaseStoreClient implements StoreBillingClient {
  final InAppPurchase _purchases;
  final PlatformPurchaseFlow _flow;
  final Map<String, ProductDetails> _products = {};

  InAppPurchaseStoreClient({required this._purchases, required this._flow});

  @override
  Stream<List<StoreTransaction>> transactions() =>
      _purchases.purchaseStream.map((details) => [for (final detail in details) storeTransactionOf(detail)]);

  @override
  Future<Map<String, String>> prices(Set<String> productIds) async {
    if (!await _purchases.isAvailable()) return const {};
    final response = await _purchases.queryProductDetails(productIds);
    for (final product in response.productDetails.where(_flow.sells)) {
      _products[product.id] = product;
    }
    return {for (final product in response.productDetails.where(_flow.sells)) product.id: product.price};
  }

  @override
  Future<bool> buy(String productId, {required bool consumable, required String? accountToken}) async {
    final product = _products[productId] ?? (await _query(productId));
    if (product == null) return false;
    final parameters = PurchaseParam(productDetails: product, applicationUserName: accountToken);
    return consumable
        ? _purchases.buyConsumable(purchaseParam: parameters, autoConsume: _flow.consumesWhenPurchased)
        : _purchases.buyNonConsumable(purchaseParam: parameters);
  }

  @override
  Future<void> complete(StoreTransaction transaction, {required bool consumable}) async {
    final details = transaction.handle;
    if (details is PurchaseDetails) await _flow.complete(details, consumable: consumable);
  }

  @override
  Future<void> restore(String? accountToken) => _purchases.restorePurchases(applicationUserName: accountToken);

  Future<ProductDetails?> _query(String productId) async {
    await prices({productId});
    return _products[productId];
  }
}
