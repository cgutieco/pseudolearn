import '../analysis/program_node_id.dart';

final class ExecutionStackFrame {
  final List<ProgramNodeId> statementNodes;

  ExecutionStackFrame({required List<ProgramNodeId> statementNodes})
    : statementNodes = List.unmodifiable(statementNodes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutionStackFrame &&
          _sameNodes(statementNodes, other.statementNodes);

  @override
  int get hashCode => Object.hashAll(statementNodes);
}

bool _sameNodes(List<ProgramNodeId> left, List<ProgramNodeId> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
