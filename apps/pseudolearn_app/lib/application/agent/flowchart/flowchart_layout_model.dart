import '../../../domain/model/agent/flowchart.dart';

const double _labelPosition = 0.6;

final class NodeExtent {
  final double width;
  final double height;

  const NodeExtent({required this.width, required this.height});

  static const NodeExtent none = NodeExtent(width: 0, height: 0);
}

final class FlowchartSpacing {
  final double rankGap;
  final double nodeGap;
  final double margin;

  const FlowchartSpacing({required this.rankGap, required this.nodeGap, required this.margin});
}

final class LayoutPoint {
  final double x;
  final double y;

  const LayoutPoint(this.x, this.y);
}

final class PlacedNode {
  final FlowchartNode node;
  final double left;
  final double top;
  final double width;
  final double height;

  const PlacedNode({
    required this.node,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  LayoutPoint get center => LayoutPoint(left + width / 2, top + height / 2);
}

final class RoutedEdge {
  final FlowchartEdge edge;
  final List<LayoutPoint> points;

  const RoutedEdge({required this.edge, required this.points});

  LayoutPoint get labelAnchor {
    if (points.isEmpty) return const LayoutPoint(0, 0);
    final middle = (points.length - 1) ~/ 2;
    final first = points[middle];
    final second = points[middle + 1 < points.length ? middle + 1 : middle];
    return LayoutPoint(
      first.x + (second.x - first.x) * _labelPosition,
      first.y + (second.y - first.y) * _labelPosition,
    );
  }
}

final class FlowchartLayout {
  final List<PlacedNode> nodes;
  final List<RoutedEdge> edges;
  final double width;
  final double height;

  const FlowchartLayout({
    required this.nodes,
    required this.edges,
    required this.width,
    required this.height,
  });
}
