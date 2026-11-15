import '../../domain/model/credits/agent_product.dart';
import '../../domain/ports/pending_purchases.dart';

final class NoPendingPurchases implements PendingPurchases {
  const NoPendingPurchases();

  @override
  Stream<PurchaseReceipt> pendingReceipts() => const Stream.empty();

  @override
  Future<void> finish(PurchaseReceipt receipt) async {}

  @override
  Future<void> restore() async {}
}
