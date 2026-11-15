import '../analysis/program_node_id.dart';

enum DiagramUnitKind {
  algorithm,
  subroutine,
  constructor,
  method,
}

final class DiagramUnit {
  final String id;
  final String displayName;
  final DiagramUnitKind kind;
  final String? className;
  final String name;
  final int sourceLine;
  final ProgramNodeId nodeId;

  const DiagramUnit({
    required this.id,
    required this.displayName,
    required this.kind,
    this.className,
    required this.name,
    required this.sourceLine,
    required this.nodeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagramUnit &&
          id == other.id &&
          displayName == other.displayName &&
          kind == other.kind &&
          className == other.className &&
          name == other.name &&
          sourceLine == other.sourceLine &&
          nodeId == other.nodeId;

  @override
  int get hashCode => Object.hash(
        id,
        displayName,
        kind,
        className,
        name,
        sourceLine,
        nodeId,
      );
}
