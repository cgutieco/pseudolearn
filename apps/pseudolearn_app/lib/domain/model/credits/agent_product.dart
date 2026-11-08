enum AgentProduct {
  trial('pseudolearn.plus.trial'),
  monthly('pseudolearn.plus.monthly'),
  topUp('pseudolearn.plus.topup150');

  final String storeId;

  const AgentProduct(this.storeId);
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
