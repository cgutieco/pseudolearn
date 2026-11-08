import '../../domain/model/credits/agent_product.dart';
import '../../domain/ports/identifier_generator.dart';
import '../../domain/ports/purchase_store.dart';

final class SimulatedPurchaseStore implements PurchaseStore {
  static const String store = 'simulated';

  final IdentifierGenerator _identifiers;

  const SimulatedPurchaseStore(this._identifiers);

  @override
  Future<PurchaseReceipt?> purchase(AgentProduct product) async => PurchaseReceipt(
    product: product,
    store: store,
    transactionId: _identifiers.generate(),
  );
}
