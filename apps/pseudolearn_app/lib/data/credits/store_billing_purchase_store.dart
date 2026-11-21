import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/model/credits/purchase_channel.dart';
import '../../domain/ports/external_url_launcher.dart';
import '../../domain/ports/purchase_store.dart';
import 'store_billing_client.dart';
import 'store_billing_profile.dart';
import 'store_transaction_queue.dart';

final class StoreBillingPurchaseStore implements PurchaseStore {
  static const List<AgentProduct> _sold = [AgentProduct.monthly, AgentProduct.topUp];

  final StoreBillingClient _client;
  final StoreTransactionQueue _queue;
  final StoreBillingProfile _profile;
  final String? Function() _accountToken;
  final ExternalUrlLauncher _launcher;

  const StoreBillingPurchaseStore({
    required this._client,
    required this._queue,
    required this._profile,
    required this._accountToken,
    required this._launcher,
  });

  @override
  PurchaseChannel get channel => _profile.channel;

  @override
  Future<PurchaseAttempt> purchase(AgentProduct product) async {
    if (!_sold.contains(product)) return const PurchaseRefused(CreditFailure.purchasesDisabled);
    return _queue.track(
      product,
      () => _client.buy(product.storeId, consumable: product.consumable, accountToken: _accountToken()),
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
  Future<bool> manageSubscription() => _launcher.launchExternalUrl(_profile.subscriptionsPage);
}
