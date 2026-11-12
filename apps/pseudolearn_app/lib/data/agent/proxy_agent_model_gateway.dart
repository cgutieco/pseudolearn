import 'dart:async';
import 'dart:io';
import '../../domain/model/agent/model_outcome.dart';
import '../../domain/model/agent/model_request.dart';
import '../../domain/model/credits/credit_failure.dart';
import '../../domain/ports/access_token_source.dart';
import '../../domain/ports/agent_model_gateway.dart';
import '../credits/credit_headers.dart';
import 'json_http_client.dart';
import 'responses_codec.dart';

final class ProxyAgentModelGateway implements AgentModelGateway {
  final String _functionsUrl;
  final AccessTokenSource _tokens;
  final JsonHttpSender _send;

  const ProxyAgentModelGateway({
    required this._functionsUrl,
    required this._tokens,
    this._send = sendJson,
  });

  @override
  Future<ModelOutcome> respond(
    ModelRequest request, {
    required String requestId,
    required String turnId,
  }) async {
    final token = await _tokens.accessToken();
    if (token == null) return const ModelFailed(CreditFailure.unauthenticated);
    try {
      final reply = await _send(
        'POST',
        functionsEndpoint(_functionsUrl, 'agent-responses'),
        headers: {
          'authorization': 'Bearer $token',
          'x-request-id': requestId,
          'x-pseudolearn-turn-id': turnId,
        },
        body: encodeResponsesRequest(request),
      );
      return _outcomeOf(reply);
    } on SocketException {
      return const ModelFailed(CreditFailure.offline, retryable: true);
    } on TimeoutException {
      return const ModelFailed(CreditFailure.offline, retryable: true);
    } on HttpException {
      return const ModelFailed(CreditFailure.offline, retryable: true);
    }
  }

  ModelOutcome _outcomeOf(JsonHttpReply reply) {
    if (reply.status != 200) {
      return ModelFailed(creditFailureOf(reply.body), retryable: retryableOf(reply.body));
    }
    return ModelAnswered(
      items: decodeResponsesOutput(reply.body),
      balance: creditBalanceFromHeaders(reply.header),
    );
  }
}
