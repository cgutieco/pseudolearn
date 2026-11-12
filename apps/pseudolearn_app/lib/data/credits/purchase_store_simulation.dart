import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/model/credits/purchase_channel.dart';
import '../../domain/ports/identifier_generator.dart';
import '../../domain/ports/purchase_store.dart';

final class SimulatedPurchaseStore implements PurchaseStore {
  final IdentifierGenerator _identifiers;

  const SimulatedPurchaseStore(this._identifiers);

  @override
  PurchaseChannel get channel => PurchaseChannel.simulated;

  @override
  Future<PurchaseAttempt> purchase(AgentProduct product) async => PurchaseConfirmed(
    PurchaseReceipt(product: product, store: channel.wireName, transactionId: _identifiers.generate()),
  );

  @override
  Future<Map<AgentProduct, String>> prices() async => const {};

  @override
  Future<bool> manageSubscription() async => false;
}
