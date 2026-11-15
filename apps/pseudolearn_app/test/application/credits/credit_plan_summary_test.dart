import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/credits/credit_plan_summary.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';

void main() {
  final renewal = DateTime.utc(2026, 11, 15);

  test('a monthly plan splits the balance into the month and the top-ups', () {
    final plan = CreditPlanSummary.of(CreditBalance(remaining: 166, allowance: 300, topUp: 38, renewsAt: renewal), periodActive: true);
    expect(plan.kind, CreditPlanKind.monthly);
    expect(plan.remaining, 166);
    expect(plan.monthlyRemaining, 128);
    expect(plan.topUp, 38);
    expect(plan.monthlyFraction, closeTo(128 / 300, 1e-9));
    expect(plan.renewsAt, renewal);
    expect(plan.hasTopUp, isTrue);
  });

  test('a trial is named as a trial', () {
    final plan = CreditPlanSummary.of(const CreditBalance(remaining: 40, allowance: 40, topUp: 0, trial: true), periodActive: true);
    expect(plan.kind, CreditPlanKind.trial);
    expect(plan.monthlyFraction, 1);
    expect(plan.hasTopUp, isFalse);
  });

  test('a lapsed plan keeps only top-ups and hides the renewal', () {
    final plan = CreditPlanSummary.of(CreditBalance(remaining: 150, allowance: 0, topUp: 150, renewsAt: renewal), periodActive: false);
    expect(plan.kind, CreditPlanKind.topUpOnly);
    expect(plan.hasMonthlyAllowance, isFalse);
    expect(plan.monthlyFraction, 0);
    expect(plan.renewsAt, isNull);
  });

  test('inconsistent balances never produce a negative or overflowing meter', () {
    final overdrawn = CreditPlanSummary.of(const CreditBalance(remaining: -5, allowance: 300, topUp: 10), periodActive: true);
    expect(overdrawn.remaining, 0);
    expect(overdrawn.monthlyRemaining, 0);
    expect(overdrawn.monthlyFraction, 0);
    final overfull = CreditPlanSummary.of(const CreditBalance(remaining: 900, allowance: 300, topUp: 0), periodActive: true);
    expect(overfull.monthlyRemaining, 300);
    expect(overfull.monthlyFraction, 1);
  });

  test('an empty balance is an empty plan', () {
    final plan = CreditPlanSummary.of(const CreditBalance.empty(), periodActive: true);
    expect(plan.remaining, 0);
    expect(plan.monthlyFraction, 0);
  });
}
