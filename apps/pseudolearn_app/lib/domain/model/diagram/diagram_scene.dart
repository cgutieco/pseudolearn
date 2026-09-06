import '../analysis/program_node_id.dart';

enum DiagramShape {
  startEnd,
  process,
  decision,
  inputOutput,
  subprogram,
  preparation,
  connector,
  cellProcess,
  cellCall,
  cellExit,
  cellEmpty,
  cellCondition,
  cellCase,
  cellLabel,
  cellLoopHeader,
  cellLoopStrip,
  classFrame,
  classHeader,
  classCompartment,
  classRow,
}

enum DiagramEdgeKind {
  normal,
  branchTrue,
  branchFalse,
  branchCase,
  loopBack,
  generalization,
  association,
}

final class DiagramPoint {
  final double x;
  final double y;

  const DiagramPoint(this.x, this.y);

  DiagramPoint shifted(double dx, double dy) => DiagramPoint(x + dx, y + dy);
}

final class DiagramNode {
  final String id;
  final DiagramShape shape;
  final List<String> lines;
  final double x;
  final double y;
  final double width;
  final double height;
  final int? sourceLine;
  final ProgramNodeId? nodeId;

  const DiagramNode({
    required this.id,
    required this.shape,
    required this.lines,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sourceLine,
    this.nodeId,
  });

  DiagramNode shifted(double dx, double dy) => DiagramNode(
        id: id,
        shape: shape,
        lines: lines,
        x: x + dx,
        y: y + dy,
        width: width,
        height: height,
        sourceLine: sourceLine,
        nodeId: nodeId,
      );
}

final class DiagramEdge {
  final String fromId;
  final String toId;
  final String? label;
  final DiagramEdgeKind kind;
  final DiagramPoint? labelAnchor;
  final List<DiagramPoint> points;

  const DiagramEdge({
    required this.fromId,
    required this.toId,
    required this.points,
    this.label,
    this.kind = DiagramEdgeKind.normal,
    this.labelAnchor,
  });

  DiagramEdge shifted(double dx, double dy) => DiagramEdge(
        fromId: fromId,
        toId: toId,
        label: label,
        kind: kind,
        labelAnchor: labelAnchor?.shifted(dx, dy),
        points: points.map((point) => point.shifted(dx, dy)).toList(),
      );
}

final class DiagramScene {
  final List<DiagramNode> nodes;
  final List<DiagramEdge> edges;
  final double width;
  final double height;

  const DiagramScene({
    required this.nodes,
    required this.edges,
    required this.width,
    required this.height,
  });

  const DiagramScene.empty()
      : nodes = const [],
        edges = const [],
        width = 0.0,
        height = 0.0;

  bool get isEmpty => nodes.isEmpty;

  bool get isNotEmpty => nodes.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagramScene &&
          nodes.length == other.nodes.length &&
          edges.length == other.edges.length &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(nodes.length, edges.length, width, height);
}
