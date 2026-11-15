import 'dart:convert';
import '../../domain/model/agent/model_item.dart';
import '../../domain/model/agent/model_request.dart';
import '../../domain/model/agent/tool_definition.dart';

Map<String, Object?> encodeResponsesRequest(ModelRequest request) => {
  'instructions': request.instructions,
  'input': [for (final item in request.input) _encodeItem(item)],
  'tools': [for (final tool in request.tools) _encodeTool(tool)],
  'parallel_tool_calls': true,
  'reasoning': {'effort': 'low'},
};

List<ModelItem> decodeResponsesOutput(Object? body) {
  final output = body is Map<String, Object?> ? body['output'] : null;
  final items = <ModelItem>[];
  for (final entry in output is List<Object?> ? output : const <Object?>[]) {
    if (entry is! Map<String, Object?>) continue;
    final item = _decodeEntry(entry);
    if (item != null) items.add(item);
  }
  return items;
}

Map<String, Object?> _encodeItem(ModelItem item) => switch (item) {
  UserTextItem(:final text) => {'role': 'user', 'content': text},
  AssistantTextItem(:final text) => {'role': 'assistant', 'content': text},
  ToolCallItem(:final callId, :final name, :final arguments) => {
    'type': 'function_call',
    'call_id': callId,
    'name': name,
    'arguments': arguments,
  },
  ToolOutputItem(:final callId, :final output) => {
    'type': 'function_call_output',
    'call_id': callId,
    'output': output,
  },
};

Map<String, Object?> _encodeTool(ToolDefinition tool) => {
  'type': 'function',
  'name': tool.name,
  'description': tool.description,
  'parameters': tool.parameters,
};

ModelItem? _decodeEntry(Map<String, Object?> entry) {
  if (entry['type'] == 'function_call') {
    final callId = entry['call_id'];
    final name = entry['name'];
    if (callId is! String || name is! String) return null;
    final arguments = entry['arguments'];
    return ToolCallItem(
      callId: callId,
      name: name,
      arguments: arguments is String ? arguments : jsonEncode(arguments ?? {}),
    );
  }
  if (entry['type'] != 'message') return null;
  final text = _textOf(entry['content']);
  return text.isEmpty ? null : AssistantTextItem(text);
}

String _textOf(Object? content) {
  if (content is String) return content;
  final parts = <String>[];
  for (final part in content is List<Object?> ? content : const <Object?>[]) {
    if (part is Map<String, Object?> && part['text'] is String) parts.add(part['text'] as String);
  }
  return parts.join();
}
