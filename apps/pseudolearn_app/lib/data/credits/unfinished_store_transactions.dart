import 'store_billing_client.dart';

abstract interface class UnfinishedStoreTransactions {
  Future<List<StoreTransaction>> unfinished();
}

final class StoreRedeliversUnfinishedTransactions implements UnfinishedStoreTransactions {
  const StoreRedeliversUnfinishedTransactions();

  @override
  Future<List<StoreTransaction>> unfinished() async => const [];
}
