import 'package:in_app_purchase/in_app_purchase.dart';

abstract interface class PlatformPurchaseFlow {
  bool get consumesWhenPurchased;

  bool sells(ProductDetails product);

  Future<void> complete(PurchaseDetails purchase, {required bool consumable});
}
