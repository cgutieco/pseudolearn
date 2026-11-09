enum StoreTransactionStatus { pending, purchased, restored, canceled, error }

final class StoreTransaction {
  final String productId;
  final String transactionId;
  final String evidence;
  final StoreTransactionStatus status;
  final Object handle;

  const StoreTransaction({
    required this.productId,
    required this.transactionId,
    required this.evidence,
    required this.status,
    required this.handle,
  });
}

abstract interface class StoreKitClient {
  Stream<List<StoreTransaction>> transactions();

  Future<Map<String, String>> prices(Set<String> productIds);

  Future<bool> buy(String productId, {required bool consumable, required String? accountToken});

  Future<void> complete(StoreTransaction transaction);

  Future<void> restore(String? accountToken);
}
