import 'package:in_app_purchase/in_app_purchase.dart';
import 'store_billing_client.dart';

const Map<PurchaseStatus, StoreTransactionStatus> _statuses = {
  PurchaseStatus.pending: StoreTransactionStatus.pending,
  PurchaseStatus.purchased: StoreTransactionStatus.purchased,
  PurchaseStatus.restored: StoreTransactionStatus.restored,
  PurchaseStatus.canceled: StoreTransactionStatus.canceled,
  PurchaseStatus.error: StoreTransactionStatus.error,
};

StoreTransaction storeTransactionOf(PurchaseDetails detail) {
  final evidence = detail.verificationData.serverVerificationData;
  final purchaseId = detail.purchaseID ?? '';
  return StoreTransaction(
    productId: detail.productID,
    transactionId: purchaseId.isEmpty ? evidence : purchaseId,
    evidence: evidence,
    status: _statuses[detail.status] ?? StoreTransactionStatus.error,
    handle: detail,
  );
}
