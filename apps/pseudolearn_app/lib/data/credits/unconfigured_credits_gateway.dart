import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/credits_outcome.dart';
import '../../domain/ports/credits_gateway.dart';

final class UnconfiguredCreditsGateway implements CreditsGateway {
  const UnconfiguredCreditsGateway();

  @override
  Future<CreditsOutcome> balance() async => const CreditsUnavailable(CreditFailure.modelUnconfigured);

  @override
  Future<CreditsOutcome> redeem(PurchaseReceipt receipt) async =>
      const CreditsUnavailable(CreditFailure.modelUnconfigured);
}
