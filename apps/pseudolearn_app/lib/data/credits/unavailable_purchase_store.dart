import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/model/credits/purchase_channel.dart';
import '../../domain/ports/purchase_store.dart';

final class UnavailablePurchaseStore implements PurchaseStore {
  const UnavailablePurchaseStore();

  @override
  PurchaseChannel get channel => PurchaseChannel.unavailable;

  @override
  Future<PurchaseAttempt> purchase(AgentProduct product) async => const PurchaseRefused(CreditFailure.purchasesDisabled);

  @override
  Future<Map<AgentProduct, String>> prices() async => const {};

  @override
  Future<bool> manageSubscription() async => false;
}
