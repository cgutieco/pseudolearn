import 'dart:async';
import 'dart:io';
import '../../domain/model/credits/agent_product.dart';
import '../../domain/model/credits/checkout_link.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/ports/access_token_source.dart';
import '../../domain/ports/checkout_gateway.dart';
import '../agent/json_http_client.dart';
import 'credit_headers.dart';

final class ProxyCheckoutGateway implements CheckoutGateway {
  final String _functionsUrl;
  final AccessTokenSource _tokens;
  final JsonHttpSender _send;

  const ProxyCheckoutGateway({
    required this._functionsUrl,
    required this._tokens,
    this._send = sendJson,
  });

  @override
  Future<CheckoutLink> checkout(AgentProduct product) =>
      _link('agent-credits/checkouts', {'product_id': product.storeId});

  @override
  Future<CheckoutLink> portal() => _link('agent-credits/portal', const {});

  Future<CheckoutLink> _link(String path, Map<String, Object?> body) async {
    final token = await _tokens.accessToken();
    if (token == null) return const CheckoutLinkRefused(CreditFailure.unauthenticated);
    try {
      final reply = await _send(
        'POST',
        functionsEndpoint(_functionsUrl, path),
        headers: {'authorization': 'Bearer $token'},
        body: body,
      );
      final json = reply.body is Map<String, Object?> ? reply.body as Map<String, Object?> : const <String, Object?>{};
      final url = Uri.tryParse(json['url'] is String ? json['url'] as String : '');
      if (reply.status != 200 || url == null || url.scheme != 'https') {
        return CheckoutLinkRefused(creditFailureOf(reply.body));
      }
      return CheckoutLinkReady(url);
    } on SocketException {
      return const CheckoutLinkRefused(CreditFailure.offline);
    } on TimeoutException {
      return const CheckoutLinkRefused(CreditFailure.offline);
    }
  }
}
