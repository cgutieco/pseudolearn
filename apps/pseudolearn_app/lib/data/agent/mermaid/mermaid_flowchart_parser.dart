import '../../../domain/model/agent/flowchart.dart';
import 'mermaid_graph_builder.dart';
import 'mermaid_statement_reader.dart';

final RegExp _header = RegExp(r'^(flowchart|graph)(\s+(TD|TB|BT|LR|RL))?\s*$', caseSensitive: false);

const Map<String, FlowchartDirection> _directions = {
  'TD': FlowchartDirection.down,
  'TB': FlowchartDirection.down,
  'BT': FlowchartDirection.up,
  'LR': FlowchartDirection.right,
  'RL': FlowchartDirection.left,
};

const Set<String> _ignoredKeywords = {
  'subgraph',
  'end',
  'style',
  'classdef',
  'class',
  'click',
  'linkstyle',
  'direction',
  'acctitle',
  'accdescr',
};

Flowchart? parseMermaidFlowchart(String source) {
  final statements = _statements(source);
  if (statements.isEmpty) return null;
  final header = _header.firstMatch(statements.first);
  if (header == null) return null;
  final graph = MermaidGraphBuilder();
  for (final statement in statements.skip(1)) {
    if (!_ignoredKeywords.contains(_firstWord(statement))) readMermaidStatement(statement, graph);
  }
  if (graph.isEmpty) return null;
  return graph.build(_directions[(header.group(3) ?? 'TD').toUpperCase()] ?? FlowchartDirection.down);
}

List<String> _statements(String source) => [
  for (final line in source.split('\n'))
    for (final statement in _splitOutsideQuotes(_withoutComment(line)))
      if (statement.trim().isNotEmpty) statement.trim(),
];

String _withoutComment(String line) {
  final comment = line.indexOf('%%');
  return comment < 0 ? line : line.substring(0, comment);
}

List<String> _splitOutsideQuotes(String line) {
  final parts = <String>[];
  var quoted = false;
  var start = 0;
  for (var index = 0; index < line.length; index += 1) {
    final character = line[index];
    if (character == '"') quoted = !quoted;
    if (character == ';' && !quoted) {
      parts.add(line.substring(start, index));
      start = index + 1;
    }
  }
  parts.add(line.substring(start));
  return parts;
}

String _firstWord(String statement) {
  final match = RegExp(r'^[A-Za-z]+').firstMatch(statement);
  return (match?.group(0) ?? '').toLowerCase();
}
