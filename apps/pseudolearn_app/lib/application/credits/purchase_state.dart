import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/purchase_channel.dart';

enum PurchaseStatus { idle, purchasing, completed, cancelled, failed, continuesOutside }

final class PurchaseState {
  final PurchaseStatus status;
  final AgentProduct? product;
  final CreditFailure? failure;
  final PurchaseChannel channel;
  final Map<AgentProduct, String> prices;

  const PurchaseState({
    this.status = PurchaseStatus.idle,
    this.product,
    this.failure,
    this.channel = PurchaseChannel.simulated,
    this.prices = const {},
  });

  PurchaseState withStatus(PurchaseStatus status, {AgentProduct? product, CreditFailure? failure}) =>
      PurchaseState(status: status, product: product, failure: failure, channel: channel, prices: prices);

  PurchaseState withPrices(Map<AgentProduct, String> prices) =>
      PurchaseState(status: status, product: product, failure: failure, channel: channel, prices: prices);

  String? priceOf(AgentProduct product) => prices[product];

  CreditFailure? get topUpFailure =>
      status == PurchaseStatus.failed && product == AgentProduct.topUp ? failure : null;
}
