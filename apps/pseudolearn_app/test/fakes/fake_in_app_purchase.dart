import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

final class FakeInAppPurchase implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> updates = StreamController.broadcast();
  final List<ProductDetails> catalog;
  final List<String> bought = [];
  final List<bool> autoConsumed = [];
  final List<String?> userNames = [];
  final List<PurchaseDetails> completed = [];
  final List<String?> restoredFor = [];
  bool available;

  FakeInAppPurchase({this.catalog = const [], this.available = true});

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async => ProductDetailsResponse(
    productDetails: [for (final product in catalog) if (identifiers.contains(product.id)) product],
    notFoundIDs: const [],
  );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    bought.add(purchaseParam.productDetails.id);
    userNames.add(purchaseParam.applicationUserName);
    return true;
  }

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam, bool autoConsume = true}) async {
    autoConsumed.add(autoConsume);
    return buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async => completed.add(purchase);

  @override
  Future<void> restorePurchases({String? applicationUserName}) async => restoredFor.add(applicationUserName);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class FakeAndroidBilling implements InAppPurchaseAndroidPlatformAddition {
  final List<GooglePlayPurchaseDetails> past;
  final List<PurchaseDetails> consumed = [];

  FakeAndroidBilling({this.past = const []});

  @override
  Future<BillingResultWrapper> consumePurchase(PurchaseDetails purchase) async {
    consumed.add(purchase);
    return const BillingResultWrapper(responseCode: BillingResponse.ok);
  }

  @override
  Future<QueryPurchaseDetailsResponse> queryPastPurchases({String? applicationUserName}) async =>
      QueryPurchaseDetailsResponse(pastPurchases: past);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GooglePlayPurchaseDetails playPurchase(
  String productId, {
  String orderId = 'GPA.1',
  String token = 'token-1',
  bool acknowledged = false,
  PurchaseStateWrapper state = PurchaseStateWrapper.purchased,
}) => GooglePlayPurchaseDetails.fromPurchase(
  PurchaseWrapper(
    orderId: orderId,
    packageName: 'com.pseudolearn.app',
    purchaseTime: 0,
    purchaseToken: token,
    signature: '',
    products: [productId],
    isAutoRenewing: false,
    originalJson: '',
    isAcknowledged: acknowledged,
    purchaseState: state,
  ),
).single;

List<GooglePlayProductDetails> playSubscription(String productId, List<String?> offerIds) =>
    GooglePlayProductDetails.fromProductDetails(
      ProductDetailsWrapper(
        description: '',
        name: productId,
        productId: productId,
        productType: ProductType.subs,
        title: productId,
        subscriptionOfferDetails: [
          for (final (index, offerId) in offerIds.indexed)
            SubscriptionOfferDetailsWrapper(
              basePlanId: 'monthly',
              offerId: offerId,
              offerTags: const [],
              offerIdToken: 'offer-token-$index',
              pricingPhases: [
                PricingPhaseWrapper(
                  billingCycleCount: 0,
                  billingPeriod: 'P1M',
                  formattedPrice: offerId == null ? r'$4.99' : r'$0.00',
                  priceAmountMicros: offerId == null ? 4990000 : 0,
                  priceCurrencyCode: 'USD',
                  recurrenceMode: RecurrenceMode.infiniteRecurring,
                ),
              ],
            ),
        ],
      ),
    );

GooglePlayProductDetails playOneTime(String productId, String price) => GooglePlayProductDetails.fromProductDetails(
  ProductDetailsWrapper(
    description: '',
    name: productId,
    productId: productId,
    productType: ProductType.inapp,
    title: productId,
    oneTimePurchaseOfferDetails: OneTimePurchaseOfferDetailsWrapper(
      formattedPrice: price,
      priceAmountMicros: 2990000,
      priceCurrencyCode: 'USD',
    ),
  ),
).single;
