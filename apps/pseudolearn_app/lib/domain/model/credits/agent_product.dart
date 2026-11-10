enum AgentProduct {
  trial('pseudolearn.nodo.trial'),
  monthly('pseudolearn.nodo.monthly'),
  topUp('pseudolearn.nodo.topup150');

  final String storeId;

  const AgentProduct(this.storeId);

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
