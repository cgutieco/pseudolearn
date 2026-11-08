import '../../domain/model/credits/credit_balance.dart';
import '../../domain/model/credits/credit_failure.dart';

CreditBalance? creditBalanceFromHeaders(String? Function(String name) header) {
  final remaining = int.tryParse(header('x-pseudolearn-credits-remaining') ?? '');
  if (remaining == null) return null;
  return CreditBalance(
    remaining: remaining,
    allowance: int.tryParse(header('x-pseudolearn-credits-allowance') ?? '') ?? 0,
    topUp: int.tryParse(header('x-pseudolearn-credits-top-up') ?? '') ?? 0,
    renewsAt: DateTime.tryParse(header('x-pseudolearn-credits-renews-at') ?? ''),
    trial: header('x-pseudolearn-credits-trial') == 'true',
  );
}

const Map<String, CreditFailure> _failuresByCode = {
  'unauthenticated': CreditFailure.unauthenticated,
  'subscription_required': CreditFailure.subscriptionRequired,
  'credits_exhausted': CreditFailure.creditsExhausted,
  'request_cap': CreditFailure.requestCap,
  'rate_limited': CreditFailure.rateLimited,
  'upstream_rate_limited': CreditFailure.rateLimited,
  'model_unconfigured': CreditFailure.modelUnconfigured,
  'purchases_disabled': CreditFailure.purchasesDisabled,
  'trial_used': CreditFailure.trialUsed,
};

CreditFailure creditFailureOf(Object? body) {
  final error = body is Map<String, Object?> ? body['error'] : null;
  final code = error is Map<String, Object?> ? error['code'] : null;
  return _failuresByCode[code] ?? CreditFailure.upstream;
}

bool retryableOf(Object? body) {
  final error = body is Map<String, Object?> ? body['error'] : null;
  return error is Map<String, Object?> && error['retryable'] == true;
}
