import '../analysis/program_node_id.dart';
import '../analysis/source_range.dart';
import 'execution_branch.dart';

enum ExecutionFocusKind {
  statement,
  decision,
  subroutineEntered,
  subroutineExited,
}

final class ExecutionFocus {
  final ProgramNodeId nodeId;
  final SourceRange range;
  final ExecutionFocusKind kind;
  final ExecutionBranch? branch;
  final String? unitId;

  const ExecutionFocus({
    required this.nodeId,
    required this.range,
    required this.kind,
    this.branch,
    this.unitId,
  });

  int get startLine => range.startLine;

  int get endLine => range.endLine;

  bool get isDecision => kind == ExecutionFocusKind.decision;

  bool get isSubroutineBoundary =>
      kind == ExecutionFocusKind.subroutineEntered ||
      kind == ExecutionFocusKind.subroutineExited;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutionFocus &&
          nodeId == other.nodeId &&
          kind == other.kind &&
          branch == other.branch &&
          unitId == other.unitId &&
          range.startOffset == other.range.startOffset &&
          range.endOffset == other.range.endOffset;

  @override
  int get hashCode => Object.hash(
        nodeId,
        kind,
        branch,
        range.startOffset,
        range.endOffset,
        unitId,
      );
}
