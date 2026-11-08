import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';

enum PurchaseStatus { idle, purchasing, completed, cancelled, failed }

final class PurchaseState {
  final PurchaseStatus status;
  final AgentProduct? product;
  final CreditFailure? failure;

  const PurchaseState({this.status = PurchaseStatus.idle, this.product, this.failure});
}
