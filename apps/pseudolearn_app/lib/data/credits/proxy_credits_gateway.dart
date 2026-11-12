import 'dart:async';
import 'dart:io';
import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/model/credits/credits_outcome.dart';
import '../../domain/ports/access_token_source.dart';
import '../../domain/ports/credits_gateway.dart';
import '../agent/json_http_client.dart';
import 'credit_headers.dart';

final class ProxyCreditsGateway implements CreditsGateway {
  final String _functionsUrl;
  final AccessTokenSource _tokens;
  final JsonHttpSender _send;

  const ProxyCreditsGateway({
    required String functionsUrl,
    required AccessTokenSource tokens,
    JsonHttpSender send = sendJson,
  }) : _functionsUrl = functionsUrl,
       _tokens = tokens,
       _send = send;

  @override
  Future<CreditsOutcome> balance() => _call('GET', 'agent-credits', failureOf: creditFailureOf, unreachable: CreditFailure.offline);

  @override
  Future<CreditsOutcome> redeem(PurchaseReceipt receipt) => _call(
    'POST',
    'agent-credits/purchases',
    body: {
      'store': receipt.store,
      'product_id': receipt.product.storeId,
      'transaction_id': receipt.transactionId,
      'evidence': receipt.evidence,
    },
    failureOf: purchaseFailureOf,
    unreachable: CreditFailure.purchaseNotApplied,
  );

  Future<CreditsOutcome> _call(
    String method,
    String path, {
    Object? body,
    required CreditFailure Function(Object? body) failureOf,
    required CreditFailure unreachable,
  }) async {
    final token = await _tokens.accessToken();
    if (token == null) return const CreditsUnavailable(CreditFailure.unauthenticated);
    try {
      final reply = await _send(
        method,
        functionsEndpoint(_functionsUrl, path),
        headers: {'authorization': 'Bearer $token'},
        body: body,
      );
      final balance = creditBalanceFromHeaders(reply.header);
      if (reply.status != 200 || balance == null) {
        return CreditsUnavailable(failureOf(reply.body));
      }
      final json = reply.body is Map<String, Object?> ? reply.body as Map<String, Object?> : const <String, Object?>{};
      return CreditsKnown(
        balance,
        periodActive: json['period_active'] == true,
        trialUsed: json['trial_used'] == true,
      );
    } on SocketException {
      return CreditsUnavailable(unreachable);
    } on TimeoutException {
      return CreditsUnavailable(unreachable);
    }
  }
}
