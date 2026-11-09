import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/agent/json_http_client.dart';
import 'package:pseudolearn_app/data/credits/proxy_checkout_gateway.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/checkout_link.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/ports/access_token_source.dart';

final class _Tokens implements AccessTokenSource {
  final String? token;

  const _Tokens(this.token);

  @override
  Future<String?> accessToken() async => token;
}

ProxyCheckoutGateway _gateway(JsonHttpReply reply, {List<String>? requests, String? token = 'jwt'}) => ProxyCheckoutGateway(
  functionsUrl: 'https://p/functions/v1',
  tokens: _Tokens(token),
  send: (method, uri, {headers = const {}, body}) async {
    requests?.add('$method $uri ${headers['authorization']} $body');
    return reply;
  },
);

void main() {
  test('a checkout posts the product and returns the secure link', () async {
    final requests = <String>[];
    final gateway = _gateway(
      const JsonHttpReply(status: 200, body: {'url': 'https://pseudolearn.app/checkout?_ptxn=txn_1'}, headers: {}),
      requests: requests,
    );
    final link = await gateway.checkout(AgentProduct.topUp) as CheckoutLinkReady;
    expect(link.url.queryParameters['_ptxn'], 'txn_1');
    expect(requests.single, 'POST https://p/functions/v1/agent-credits/checkouts Bearer jwt {product_id: pseudolearn.plus.topup150}');
  });

  test('the portal posts to its own endpoint', () async {
    final requests = <String>[];
    final gateway = _gateway(
      const JsonHttpReply(status: 200, body: {'url': 'https://customer-portal.paddle.com/x'}, headers: {}),
      requests: requests,
    );
    expect(await gateway.portal(), isA<CheckoutLinkReady>());
    expect(requests.single, startsWith('POST https://p/functions/v1/agent-credits/portal'));
  });

  test('server refusals keep their code and insecure or missing links are refused', () async {
    final refused = _gateway(const JsonHttpReply(status: 409, body: {'error': {'code': 'already_subscribed'}}, headers: {}));
    expect((await refused.checkout(AgentProduct.monthly) as CheckoutLinkRefused).failure, CreditFailure.alreadySubscribed);
    final insecure = _gateway(const JsonHttpReply(status: 200, body: {'url': 'http://evil.test'}, headers: {}));
    expect(await insecure.checkout(AgentProduct.monthly), isA<CheckoutLinkRefused>());
    final empty = _gateway(const JsonHttpReply(status: 200, body: null, headers: {}));
    expect(await empty.portal(), isA<CheckoutLinkRefused>());
  });

  test('without a session or a network nothing is requested from Paddle', () async {
    final signedOut = _gateway(const JsonHttpReply(status: 200, body: null, headers: {}), token: null);
    expect((await signedOut.checkout(AgentProduct.topUp) as CheckoutLinkRefused).failure, CreditFailure.unauthenticated);
    final offline = ProxyCheckoutGateway(
      functionsUrl: 'https://p',
      tokens: const _Tokens('jwt'),
      send: (method, uri, {headers = const {}, body}) async => throw const SocketException('down'),
    );
    expect((await offline.portal() as CheckoutLinkRefused).failure, CreditFailure.offline);
  });
}
