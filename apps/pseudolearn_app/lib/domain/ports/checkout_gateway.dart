import '../model/credits/agent_product.dart';
import '../model/credits/checkout_link.dart';

abstract interface class CheckoutGateway {
  Future<CheckoutLink> checkout(AgentProduct product);

  Future<CheckoutLink> portal();
}
