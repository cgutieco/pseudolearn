import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../../domain/model/credits/agent_product.dart';
import 'platform_purchase_flow.dart';
import 'purchase_details_transaction.dart';
import 'store_billing_client.dart';
import 'unfinished_store_transactions.dart';

final class GooglePlayPurchaseFlow implements PlatformPurchaseFlow, UnfinishedStoreTransactions {
  static const Set<PurchaseStatus> _granted = {PurchaseStatus.purchased, PurchaseStatus.restored};

  final InAppPurchase _purchases;
  final InAppPurchaseAndroidPlatformAddition _billing;

  const GooglePlayPurchaseFlow({required this._purchases, required this._billing});

  @override
  bool get consumesWhenPurchased => false;

  @override
  bool sells(ProductDetails product) =>
      product is! GooglePlayProductDetails || _isBasePlanOrOneTime(product);

  @override
  Future<void> complete(PurchaseDetails purchase, {required bool consumable}) async {
    if (!_granted.contains(purchase.status)) return;
    if (consumable) {
      await _billing.consumePurchase(purchase);
    } else if (purchase.pendingCompletePurchase) {
      await _purchases.completePurchase(purchase);
    }
  }

  @override
  Future<List<StoreTransaction>> unfinished() async {
    final response = await _billing.queryPastPurchases();
    return [
      for (final purchase in response.pastPurchases)
        if (_awaitsServerGrant(purchase)) storeTransactionOf(purchase),
    ];
  }

  bool _isBasePlanOrOneTime(GooglePlayProductDetails product) {
    final index = product.subscriptionIndex;
    final offers = product.productDetails.subscriptionOfferDetails;
    return index == null || offers == null || offers[index].offerId == null;
  }

  bool _awaitsServerGrant(GooglePlayPurchaseDetails purchase) {
    if (purchase.status != PurchaseStatus.purchased) return false;
    final consumable = AgentProduct.fromStoreId(purchase.productID)?.consumable ?? false;
    return consumable || !purchase.billingClientPurchase.isAcknowledged;
  }
}
