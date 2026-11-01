import 'program_node_id.dart';

enum ProgramViewExitKind { breakLoop, returnUnit, propagation }

final class ProgramViewControlExit {
  final ProgramNodeId exitNodeId;
  final ProgramViewExitKind kind;
  final ProgramNodeId? targetNodeId;
  final List<ProgramNodeId> cleanupNodeIds;

  ProgramViewControlExit({
    required this.exitNodeId,
    required this.kind,
    required this.targetNodeId,
    required List<ProgramNodeId> cleanupNodeIds,
  }) : cleanupNodeIds = List.unmodifiable(cleanupNodeIds);
}

final class ProgramViewCleanupScope {
  final ProgramNodeId bodyNodeId;
  final List<ProgramNodeId> cleanupNodeIds;

  ProgramViewCleanupScope({
    required this.bodyNodeId,
    required List<ProgramNodeId> cleanupNodeIds,
  }) : cleanupNodeIds = List.unmodifiable(cleanupNodeIds);
}
