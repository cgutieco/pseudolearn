enum AgentProduct {
  trial('pseudolearn.nodo.trial', consumable: false),
  monthly('pseudolearn.nodo.monthly', consumable: false),
  topUp('pseudolearn.nodo.topup150', consumable: true);

  final String storeId;
  final bool consumable;

  const AgentProduct(this.storeId, {required this.consumable});

  static AgentProduct? fromStoreId(String storeId) {
    for (final product in values) {
      if (product.storeId == storeId) return product;
    }
    return null;
  }
}

final class PurchaseReceipt {
  final AgentProduct product;
  final String store;
  final String transactionId;
  final String evidence;

  const PurchaseReceipt({
    required this.product,
    required this.store,
    required this.transactionId,
    this.evidence = '',
  });
}
