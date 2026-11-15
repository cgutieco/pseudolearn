import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/credits/credit_headers.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/credits/purchase_channel.dart';

void main() {
  test('the balance names the store that manages the plan', () {
    final headers = {'x-pseudolearn-credits-remaining': '12', 'x-pseudolearn-credits-store': 'paddle'};
    expect(creditBalanceFromHeaders((name) => headers[name])?.managedBy, PurchaseChannel.paddle);
  });

  test('an empty or unknown store leaves the plan without a manager', () {
    for (final store in ['', 'google_play']) {
      final headers = {'x-pseudolearn-credits-remaining': '0', 'x-pseudolearn-credits-store': store};
      expect(creditBalanceFromHeaders((name) => headers[name])?.managedBy, isNull);
    }
  });

  test('store refusals map to their own failures', () {
    Map<String, Object?> body(String code) => {'error': {'code': code}};
    expect(creditFailureOf(body('already_subscribed')), CreditFailure.alreadySubscribed);
    expect(creditFailureOf(body('purchase_owned_elsewhere')), CreditFailure.purchaseOwnedElsewhere);
    expect(creditFailureOf(body('invalid_signature')), CreditFailure.invalidPurchase);
    expect(creditFailureOf(body('invalid_request')), CreditFailure.upstream);
  });

  test('purchase refusals keep their own failures and anything unknown is a purchase not applied', () {
    Map<String, Object?> body(String code) => {'error': {'code': code}};
    expect(purchaseFailureOf(body('invalid_request')), CreditFailure.invalidPurchase);
    expect(purchaseFailureOf(body('invalid_product')), CreditFailure.invalidPurchase);
    expect(purchaseFailureOf(body('invalid_signature')), CreditFailure.invalidPurchase);
    expect(purchaseFailureOf(body('trial_used')), CreditFailure.trialUsed);
    expect(purchaseFailureOf(body('unexpected_failure')), CreditFailure.purchaseNotApplied);
    expect(purchaseFailureOf(null), CreditFailure.purchaseNotApplied);
    expect(purchaseFailureOf('?'), CreditFailure.purchaseNotApplied);
    expect(purchaseFailureOf(const {'error': 'flat'}), CreditFailure.purchaseNotApplied);
  });
}
