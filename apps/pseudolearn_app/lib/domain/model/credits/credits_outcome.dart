import 'credit_balance.dart';
import 'credit_failure.dart';

sealed class CreditsOutcome {
  const CreditsOutcome();
}

final class CreditsKnown extends CreditsOutcome {
  final CreditBalance balance;
  final bool periodActive;
  final bool trialUsed;

  const CreditsKnown(this.balance, {this.periodActive = false, this.trialUsed = false});
}

final class CreditsUnavailable extends CreditsOutcome {
  final CreditFailure failure;

  const CreditsUnavailable(this.failure);
}
