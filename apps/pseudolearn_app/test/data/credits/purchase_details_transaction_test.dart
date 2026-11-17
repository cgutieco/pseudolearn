import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pseudolearn_app/data/credits/purchase_details_transaction.dart';
import 'package:pseudolearn_app/data/credits/store_billing_client.dart';

PurchaseDetails _details({String? purchaseId, PurchaseStatus status = PurchaseStatus.purchased}) => PurchaseDetails(
  purchaseID: purchaseId,
  productID: 'pseudolearn.nodo.monthly',
  verificationData: PurchaseVerificationData(localVerificationData: '', serverVerificationData: 'evidence', source: 'test'),
  transactionDate: null,
  status: status,
);

void main() {
  test('the store purchase id names the transaction and the server data is its evidence', () {
    final transaction = storeTransactionOf(_details(purchaseId: '2000001'));
    expect(transaction.transactionId, '2000001');
    expect(transaction.evidence, 'evidence');
    expect(transaction.productId, 'pseudolearn.nodo.monthly');
  });

  test('a purchase without an order id is named by its evidence', () {
    expect(storeTransactionOf(_details()).transactionId, 'evidence');
    expect(storeTransactionOf(_details(purchaseId: '')).transactionId, 'evidence');
  });

  test('every store status maps to its transaction status', () {
    expect(
      [for (final status in PurchaseStatus.values) storeTransactionOf(_details(status: status)).status],
      [
        StoreTransactionStatus.pending,
        StoreTransactionStatus.purchased,
        StoreTransactionStatus.error,
        StoreTransactionStatus.restored,
        StoreTransactionStatus.canceled,
      ],
    );
  });
}
