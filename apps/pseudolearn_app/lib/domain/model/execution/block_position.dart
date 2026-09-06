import '../analysis/program_node_id.dart';

final class BlockPosition {
  final int depth;
  final ProgramNodeId? enclosingNodeId;

  const BlockPosition({required this.depth, this.enclosingNodeId});

  const BlockPosition.outermost()
      : depth = 0,
        enclosingNodeId = null;

  bool get hasEnclosingBlock => enclosingNodeId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockPosition &&
          depth == other.depth &&
          enclosingNodeId == other.enclosingNodeId;

  @override
  int get hashCode => Object.hash(depth, enclosingNodeId);
}
