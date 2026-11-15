import '../model/credits/agent_product.dart';
import '../model/credits/credits_outcome.dart';

abstract interface class CreditsGateway {
  Future<CreditsOutcome> balance();
  Future<CreditsOutcome> redeem(PurchaseReceipt receipt);
}
