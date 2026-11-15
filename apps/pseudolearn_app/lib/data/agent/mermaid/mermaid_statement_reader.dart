import 'mermaid_graph_builder.dart';
import 'mermaid_label.dart';
import 'mermaid_link.dart';
import 'mermaid_node_shapes.dart';

final RegExp _identifier = RegExp(r'\s*([\p{L}\p{N}_]+)', unicode: true);
final RegExp _styleClass = RegExp(r':::[\w-]+');
final RegExp _ampersand = RegExp(r'\s*&');

final class _NodeGroup {
  final List<String> ids;
  final int end;

  const _NodeGroup(this.ids, this.end);
}

void readMermaidStatement(String statement, MermaidGraphBuilder graph) {
  var group = _nodeGroup(statement, 0, graph);
  while (group != null) {
    final link = matchMermaidLink(statement, group.end);
    if (link == null) return;
    final next = _nodeGroup(statement, link.end, graph);
    if (next == null) return;
    for (final from in group.ids) {
      for (final to in next.ids) {
        graph.connect(link.between(from, to));
      }
    }
    group = next;
  }
}

_NodeGroup? _nodeGroup(String text, int position, MermaidGraphBuilder graph) {
  final ids = <String>[];
  var cursor = position;
  while (true) {
    final end = _node(text, cursor, graph: graph, ids: ids);
    if (end == null) return ids.isEmpty ? null : _NodeGroup(ids, cursor);
    final ampersand = _ampersand.matchAsPrefix(text, end);
    if (ampersand == null) return _NodeGroup(ids, end);
    cursor = ampersand.end;
  }
}

int? _node(String text, int position, {required MermaidGraphBuilder graph, required List<String> ids}) {
  final identifier = _identifier.matchAsPrefix(text, position);
  if (identifier == null) return null;
  final id = identifier.group(1)!;
  final shape = matchMermaidShape(text, identifier.end);
  if (shape == null) {
    graph.declare(id);
  } else {
    graph.declare(id, label: cleanMermaidLabel(shape.label), shape: shape.shape);
  }
  ids.add(id);
  final end = shape?.end ?? identifier.end;
  return _styleClass.matchAsPrefix(text, end)?.end ?? end;
}
