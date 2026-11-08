enum FlowchartDirection { down, up, right, left }

enum FlowchartShape {
  rectangle,
  rounded,
  stadium,
  circle,
  diamond,
  hexagon,
  parallelogram,
  trapezoid,
  subroutine,
  cylinder,
  flag,
}

enum FlowchartStroke { solid, dotted, thick, invisible }

final class FlowchartNode {
  final String id;
  final String label;
  final FlowchartShape shape;

  const FlowchartNode({required this.id, required this.label, this.shape = FlowchartShape.rectangle});
}

final class FlowchartEdge {
  final String from;
  final String to;
  final String label;
  final FlowchartStroke stroke;
  final bool arrowAtStart;
  final bool arrowAtEnd;

  const FlowchartEdge({
    required this.from,
    required this.to,
    this.label = '',
    this.stroke = FlowchartStroke.solid,
    this.arrowAtStart = false,
    this.arrowAtEnd = true,
  });
}

final class Flowchart {
  final FlowchartDirection direction;
  final List<FlowchartNode> nodes;
  final List<FlowchartEdge> edges;

  const Flowchart({required this.direction, required this.nodes, required this.edges});
}
