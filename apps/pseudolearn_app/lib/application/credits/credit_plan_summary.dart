import '../../domain/model/credits/credit_balance.dart';

enum CreditPlanKind { trial, monthly, topUpOnly }

final class CreditPlanSummary {
  final int remaining;
  final int monthlyRemaining;
  final int allowance;
  final int topUp;
  final CreditPlanKind kind;
  final DateTime? renewsAt;

  const CreditPlanSummary({
    required this.remaining,
    required this.monthlyRemaining,
    required this.allowance,
    required this.topUp,
    required this.kind,
    this.renewsAt,
  });

  factory CreditPlanSummary.of(CreditBalance balance, {required bool periodActive}) {
    final monthly = (balance.remaining - balance.topUp).clamp(0, balance.allowance);
    return CreditPlanSummary(
      remaining: balance.remaining < 0 ? 0 : balance.remaining,
      monthlyRemaining: monthly,
      allowance: balance.allowance,
      topUp: balance.topUp,
      kind: _kindOf(balance, periodActive),
      renewsAt: periodActive ? balance.renewsAt : null,
    );
  }

  double get monthlyFraction => allowance <= 0 ? 0 : monthlyRemaining / allowance;

  bool get hasMonthlyAllowance => allowance > 0;

  bool get hasTopUp => topUp > 0;

  static CreditPlanKind _kindOf(CreditBalance balance, bool periodActive) {
    if (!periodActive) return CreditPlanKind.topUpOnly;
    return balance.trial ? CreditPlanKind.trial : CreditPlanKind.monthly;
  }
}
