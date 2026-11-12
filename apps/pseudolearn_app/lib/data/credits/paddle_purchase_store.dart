import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/checkout_link.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_attempt.dart';
import '../../domain/model/credits/purchase_channel.dart';
import '../../domain/ports/checkout_gateway.dart';
import '../../domain/ports/external_url_launcher.dart';
import '../../domain/ports/purchase_store.dart';

final class PaddlePurchaseStore implements PurchaseStore {
  final CheckoutGateway _checkouts;
  final ExternalUrlLauncher _launcher;

  const PaddlePurchaseStore({required this._checkouts, required this._launcher});

  @override
  PurchaseChannel get channel => PurchaseChannel.paddle;

  @override
  Future<PurchaseAttempt> purchase(AgentProduct product) async {
    final link = await _checkouts.checkout(product);
    return switch (link) {
      CheckoutLinkRefused(:final failure) => PurchaseRefused(failure),
      CheckoutLinkReady(:final url) => await _launcher.launchExternalUrl(url)
          ? const PurchaseContinuesOutside()
          : const PurchaseRefused(CreditFailure.upstream),
    };
  }

  @override
  Future<Map<AgentProduct, String>> prices() async => const {};

  @override
  Future<bool> manageSubscription() async {
    final link = await _checkouts.portal();
    return switch (link) {
      CheckoutLinkRefused() => false,
      CheckoutLinkReady(:final url) => await _launcher.launchExternalUrl(url),
    };
  }
}
