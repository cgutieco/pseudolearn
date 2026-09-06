import 'package:pseudolearn_core/pseudolearn_core.dart';

final class NodeSpanIndex {
  final Map<NodeId, Span> _spans;

  const NodeSpanIndex._(this._spans);

  const NodeSpanIndex.empty() : _spans = const {};

  factory NodeSpanIndex.of(SourceUnitNode unit) {
    final spans = <NodeId, Span>{};
    final pending = <AstNode>[unit];
    while (pending.isNotEmpty) {
      final node = pending.removeLast();
      spans[node.id] = node.span;
      pending.addAll(getChildNodes(node));
    }
    return NodeSpanIndex._(spans);
  }

  Span? spanOf(NodeId id) => _spans[id];

  int get length => _spans.length;
}
