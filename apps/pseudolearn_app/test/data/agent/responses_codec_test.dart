import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/agent/markdown_code_block_reader.dart';
import 'package:pseudolearn_app/data/agent/proxy_agent_model_gateway.dart';
import 'package:pseudolearn_app/data/agent/json_http_client.dart';
import 'package:pseudolearn_app/data/agent/responses_codec.dart';
import 'package:pseudolearn_app/data/credits/credit_headers.dart';
import 'package:pseudolearn_app/domain/model/agent/model_item.dart';
import 'package:pseudolearn_app/domain/model/agent/model_outcome.dart';
import 'package:pseudolearn_app/domain/model/agent/model_request.dart';
import 'package:pseudolearn_app/domain/model/agent/tool_definition.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/ports/access_token_source.dart';

final class _Tokens implements AccessTokenSource {
  final String? token;

  const _Tokens(this.token);

  @override
  Future<String?> accessToken() async => token;
}

const _request = ModelRequest(
  instructions: 'i',
  input: [
    UserTextItem('hola'),
    ToolCallItem(callId: 'c', name: 'n', arguments: '{}'),
    ToolOutputItem(callId: 'c', output: '{"ok":true}'),
    AssistantTextItem('ok'),
  ],
  tools: [ToolDefinition(name: 'n', description: 'd', parameters: {}, risk: ToolRisk.read, stepLabel: 's')],
);

void main() {
  test('requests use Responses API items and function tools', () {
    final body = encodeResponsesRequest(_request);
    final input = body['input'] as List<Object?>;
    expect(input[0], {'role': 'user', 'content': 'hola'});
    expect((input[1] as Map)['type'], 'function_call');
    expect((input[2] as Map)['type'], 'function_call_output');
    expect((body['tools'] as List).single, containsPair('type', 'function'));
    expect(body.containsKey('model'), isFalse);
  });

  test('replies keep text and calls and ignore reasoning and garbage', () {
    final items = decodeResponsesOutput({
      'output': [
        {'type': 'reasoning', 'summary': <Object?>[]},
        {'type': 'function_call', 'call_id': 'c1', 'name': 'check_program', 'arguments': '{"a":1}'},
        {'type': 'message', 'content': [{'type': 'output_text', 'text': 'Hola '}, {'type': 'output_text', 'text': 'mundo'}]},
        {'type': 'function_call', 'name': 'missing_id'},
        'nonsense',
      ],
    });
    expect(items, hasLength(2));
    expect((items[0] as ToolCallItem).name, 'check_program');
    expect((items[1] as AssistantTextItem).text, 'Hola mundo');
    expect(decodeResponsesOutput(null), isEmpty);
  });

  test('balance headers and error codes are translated', () {
    const headers = {
      'x-pseudolearn-credits-remaining': '12',
      'x-pseudolearn-credits-allowance': '300',
      'x-pseudolearn-credits-trial': 'true',
    };
    final balance = creditBalanceFromHeaders((name) => headers[name]);
    expect(balance!.remaining, 12);
    expect(balance.trial, isTrue);
    expect(creditBalanceFromHeaders((_) => null), isNull);
    expect(creditFailureOf({'error': {'code': 'request_cap'}}), CreditFailure.requestCap);
    expect(creditFailureOf('?'), CreditFailure.upstream);
  });

  test('the proxy gateway sends the session, request and turn ids', () async {
    final sent = <Map<String, String>>[];
    final gateway = ProxyAgentModelGateway(
      functionsUrl: 'https://p.supabase.co/functions/v1/',
      tokens: const _Tokens('jwt'),
      send: (method, uri, {headers = const {}, body}) async {
        sent.add({...headers, 'uri': '$uri'});
        return JsonHttpReply(
          status: 200,
          body: {'output': [{'type': 'message', 'content': 'hi'}]},
          headers: const {'x-pseudolearn-credits-remaining': '7'},
        );
      },
    );
    final outcome = await gateway.respond(_request, requestId: 'r', turnId: 't');
    expect(sent.single['uri'], 'https://p.supabase.co/functions/v1/agent-responses');
    expect(sent.single['authorization'], 'Bearer jwt');
    expect(sent.single['x-pseudolearn-turn-id'], 't');
    expect((outcome as ModelAnswered).balance!.remaining, 7);
  });

  test('the proxy gateway maps no session, errors and offline', () async {
    final noSession = ProxyAgentModelGateway(functionsUrl: 'u', tokens: const _Tokens(null));
    expect(((await noSession.respond(_request, requestId: 'r', turnId: 't')) as ModelFailed).failure,
        CreditFailure.unauthenticated);
    final refused = ProxyAgentModelGateway(
      functionsUrl: 'https://p',
      tokens: const _Tokens('jwt'),
      send: (method, uri, {headers = const {}, body}) async => const JsonHttpReply(
        status: 503,
        body: {'error': {'code': 'model_unconfigured', 'retryable': false}},
        headers: {},
      ),
    );
    expect(((await refused.respond(_request, requestId: 'r', turnId: 't')) as ModelFailed).failure,
        CreditFailure.modelUnconfigured);
    final offline = ProxyAgentModelGateway(
      functionsUrl: 'https://p',
      tokens: const _Tokens('jwt'),
      send: (method, uri, {headers = const {}, body}) async => throw const SocketException('down'),
    );
    final failed = await offline.respond(_request, requestId: 'r', turnId: 't') as ModelFailed;
    expect(failed.failure, CreditFailure.offline);
    expect(failed.retryable, isTrue);
  });

  test('fenced blocks are read with their language and position', () {
    const text = 'a\n```pseudolearn\nx\n```\nb\n```\ny\n```';
    final blocks = const MarkdownCodeBlockReader().read(text);
    expect(blocks.map((block) => block.language), ['pseudolearn', '']);
    expect(blocks.first.source, 'x\n');
    expect(blocks.every((block) => block.isPseudoLearn), isTrue);
    expect(const MarkdownCodeBlockReader().read('sin bloques'), isEmpty);
  });
}
