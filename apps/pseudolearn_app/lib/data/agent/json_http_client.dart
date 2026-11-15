import 'dart:convert';
import 'dart:io';
import '../../domain/model/agent/agent_network_policy.dart';

final class JsonHttpReply {
  final int status;
  final Object? body;
  final Map<String, String> headers;

  const JsonHttpReply({required this.status, required this.body, required this.headers});

  String? header(String name) => headers[name.toLowerCase()];
}

Uri functionsEndpoint(String base, String path) =>
    Uri.parse('${base.replaceAll(RegExp(r'/+$'), '')}/$path');

typedef JsonHttpSender = Future<JsonHttpReply> Function(
  String method,
  Uri uri, {
  Map<String, String> headers,
  Object? body,
});

Future<JsonHttpReply> sendJson(
  String method,
  Uri uri, {
  Map<String, String> headers = const {},
  Object? body,
}) async {
  final client = HttpClient()..connectionTimeout = AgentNetworkPolicy.connectionTimeout;
  try {
    final request = await client.openUrl(method, uri);
    headers.forEach(request.headers.set);
    request.headers.contentType = ContentType.json;
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close().timeout(AgentNetworkPolicy.responseTimeout);
    final text = await response.transform(utf8.decoder).join();
    final replyHeaders = <String, String>{};
    response.headers.forEach((name, values) => replyHeaders[name.toLowerCase()] = values.join(','));
    return JsonHttpReply(status: response.statusCode, body: _decoded(text), headers: replyHeaders);
  } finally {
    client.close();
  }
}

Object? _decoded(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    return null;
  }
}
