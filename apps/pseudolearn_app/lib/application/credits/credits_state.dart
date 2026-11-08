import '../../domain/model/credits/credit_balance.dart';
import '../../domain/model/credits/credit_failure.dart';

enum CreditsStatus { unknown, loading, known, unavailable }

final class CreditsState {
  final CreditsStatus status;
  final CreditBalance? balance;
  final bool periodActive;
  final bool trialUsed;
  final CreditFailure? failure;
  final int lastRequestSpent;

  const CreditsState({
    this.status = CreditsStatus.unknown,
    this.balance,
    this.periodActive = false,
    this.trialUsed = false,
    this.failure,
    this.lastRequestSpent = 0,
  });

  bool get needsOffer =>
      status == CreditsStatus.unavailable &&
          (failure == CreditFailure.subscriptionRequired || failure == CreditFailure.unauthenticated) ||
      status == CreditsStatus.known && !periodActive && (balance?.topUp ?? 0) == 0;

  bool get isExhausted => status == CreditsStatus.known && (balance?.isExhausted ?? false);
}
