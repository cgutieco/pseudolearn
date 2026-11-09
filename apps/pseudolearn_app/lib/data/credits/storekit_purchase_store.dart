import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/model/credits/purchase_channel.dart';
import '../../domain/ports/external_url_launcher.dart';
import '../../domain/ports/purchase_store.dart';
import 'storekit_client.dart';
import 'storekit_transaction_queue.dart';

final class StoreKitPurchaseStore implements PurchaseStore {
  static final Uri subscriptionsUrl = Uri.parse('https://apps.apple.com/account/subscriptions');
  static const List<AgentProduct> _sold = [AgentProduct.monthly, AgentProduct.topUp];

  final StoreKitClient _client;
  final StoreKitTransactionQueue _queue;
  final String? Function() _accountToken;
  final ExternalUrlLauncher _launcher;

  const StoreKitPurchaseStore({
    required StoreKitClient client,
    required StoreKitTransactionQueue queue,
    required String? Function() accountToken,
    required ExternalUrlLauncher launcher,
  }) : _client = client,
       _queue = queue,
       _accountToken = accountToken,
       _launcher = launcher;

  @override
  PurchaseChannel get channel => PurchaseChannel.appStore;

  @override
  Future<PurchaseAttempt> purchase(AgentProduct product) async {
    if (!_sold.contains(product)) return const PurchaseRefused(CreditFailure.purchasesDisabled);
    return _queue.track(
      product,
      () => _client.buy(product.storeId, consumable: product == AgentProduct.topUp, accountToken: _accountToken()),
    );
  }

  @override
  Future<Map<AgentProduct, String>> prices() async {
    final byId = await _client.prices({for (final product in _sold) product.storeId});
    return {
      for (final product in _sold)
        if (byId[product.storeId] != null) product: byId[product.storeId]!,
    };
  }

  @override
  Future<bool> manageSubscription() => _launcher.launchExternalUrl(subscriptionsUrl);
}
