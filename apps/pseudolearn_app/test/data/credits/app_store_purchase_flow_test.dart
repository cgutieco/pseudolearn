import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pseudolearn_app/data/credits/app_store_purchase_flow.dart';
import '../../fakes/fake_in_app_purchase.dart';

PurchaseDetails _details({required bool pendingCompletion}) => PurchaseDetails(
  productID: 'pseudolearn.nodo.topup150',
  verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: 'jws', source: 'app_store'),
  transactionDate: null,
  status: PurchaseStatus.purchased,
)..pendingCompletePurchase = pendingCompletion;

void main() {
  test('StoreKit consumes on purchase and sells every product it returns', () {
    final flow = AppStorePurchaseFlow(FakeInAppPurchase());
    expect(flow.consumesWhenPurchased, isTrue);
    expect(flow.sells(ProductDetails(id: 'x', title: '', description: '', price: '', rawPrice: 0, currencyCode: 'USD')), isTrue);
  });

  test('only transactions awaiting completion are finished', () async {
    final purchases = FakeInAppPurchase();
    final flow = AppStorePurchaseFlow(purchases);
    final awaiting = _details(pendingCompletion: true);
    await flow.complete(awaiting, consumable: true);
    await flow.complete(_details(pendingCompletion: false), consumable: false);
    expect(purchases.completed, [awaiting]);
  });
}
