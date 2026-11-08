import '../model/credits/agent_product.dart';

abstract interface class PurchaseStore {
  Future<PurchaseReceipt?> purchase(AgentProduct product);
}
