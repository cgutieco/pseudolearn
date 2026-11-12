import '../../domain/model/credits/credit_balance.dart';
import '../../domain/model/credits/credit_failure.dart';
import 'credit_plan_summary.dart';

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

  bool get hasAccess {
    final known = balance;
    if (known == null || failure == CreditFailure.subscriptionRequired || failure == CreditFailure.unauthenticated) {
      return false;
    }
    return periodActive || known.topUp > 0;
  }

  bool get awaitsFirstBalance => balance == null && (status == CreditsStatus.unknown || status == CreditsStatus.loading);

  CreditPlanSummary? get plan {
    final known = balance;
    return known == null ? null : CreditPlanSummary.of(known, periodActive: periodActive);
  }

  bool get topUpNeedsPlan => status == CreditsStatus.known && !periodActive;

  bool get isExhausted => status == CreditsStatus.known && (balance?.isExhausted ?? false);
}
