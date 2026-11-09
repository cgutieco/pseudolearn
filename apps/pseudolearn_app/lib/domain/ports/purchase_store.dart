import '../model/credits/agent_product.dart';
import '../model/credits/purchase_attempt.dart';
import '../model/credits/purchase_channel.dart';

abstract interface class PurchaseStore {
  PurchaseChannel get channel;

  Future<PurchaseAttempt> purchase(AgentProduct product);

  Future<Map<AgentProduct, String>> prices();

  Future<bool> manageSubscription();
}
