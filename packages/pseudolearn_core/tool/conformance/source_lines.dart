import 'package:pseudolearn_core/pseudolearn_core.dart';

Map<NodeId, int> nodeLines(AstNode root) {
  final lines = <NodeId, int>{};
  final pending = <AstNode>[root];
  while (pending.isNotEmpty) {
    final node = pending.removeLast();
    lines[node.id] = node.span.start.line;
    pending.addAll(getChildNodes(node));
  }
  return lines;
}
