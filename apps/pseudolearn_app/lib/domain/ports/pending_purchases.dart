import '../model/credits/agent_product.dart';

abstract interface class PendingPurchases {
  Stream<PurchaseReceipt> pendingReceipts();

  Future<void> finish(PurchaseReceipt receipt);

  Future<void> restore();
}
