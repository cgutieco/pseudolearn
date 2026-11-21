import 'package:in_app_purchase/in_app_purchase.dart';
import 'platform_purchase_flow.dart';

final class AppStorePurchaseFlow implements PlatformPurchaseFlow {
  final InAppPurchase _purchases;

  const AppStorePurchaseFlow(this._purchases);

  @override
  bool get consumesWhenPurchased => true;

  @override
  bool sells(ProductDetails product) => true;

  @override
  Future<void> complete(PurchaseDetails purchase, {required bool consumable}) async {
    if (purchase.pendingCompletePurchase) await _purchases.completePurchase(purchase);
  }
}
