import '../../../domain/model/agent/flowchart.dart';
import 'flowchart_layering.dart';
import 'flowchart_layout_model.dart';
import 'flowchart_placement.dart';

final class AxisFrame {
  final FlowchartDirection direction;
  final double mainExtent;

  const AxisFrame({required this.direction, required this.mainExtent});

  LayoutPoint point(double main, double cross) => switch (direction) {
    FlowchartDirection.down => LayoutPoint(cross, main),
    FlowchartDirection.up => LayoutPoint(cross, mainExtent - main),
    FlowchartDirection.right => LayoutPoint(main, cross),
    FlowchartDirection.left => LayoutPoint(mainExtent - main, cross),
  };
}

List<RoutedEdge> routedEdges({
  required Flowchart chart,
  required LayeredGraph graph,
  required AxisPlacement placement,
  required AxisFrame frame,
  required FlowchartSpacing spacing,
}) {
  final chains = {for (final chain in graph.chains) chain.edgeIndex: chain};
  final routed = <RoutedEdge>[];
  for (final (index, edge) in chart.edges.indexed) {
    final chain = chains[index];
    final points = chain != null
        ? _chainPoints(chain, placement.boxes, frame)
        : _selfLoopPoints(edge.from == edge.to ? placement.boxes[edge.from] : null, frame, spacing.nodeGap);
    if (points.isNotEmpty) routed.add(RoutedEdge(edge: edge, points: points));
  }
  return routed;
}

List<LayoutPoint> _chainPoints(LayerChain chain, Map<String, AxisBox> boxes, AxisFrame frame) {
  final path = chain.path;
  final first = boxes[path.first]!;
  final last = boxes[path.last]!;
  final points = <LayoutPoint>[
    frame.point(first.mainEnd, first.crossCenter),
    for (final id in path.sublist(1, path.length - 1)) frame.point(boxes[id]!.mainStart, boxes[id]!.crossCenter),
    frame.point(last.mainStart, last.crossCenter),
  ];
  return chain.reversed ? points.reversed.toList() : points;
}

List<LayoutPoint> _selfLoopPoints(AxisBox? box, AxisFrame frame, double reach) {
  if (box == null) return const [];
  final crossEdge = box.crossCenter + box.crossSize / 2;
  final nearMain = box.mainStart + box.mainSize / 4;
  final farMain = box.mainStart + box.mainSize * 3 / 4;
  return [
    frame.point(nearMain, crossEdge),
    frame.point(nearMain, crossEdge + reach),
    frame.point(farMain, crossEdge + reach),
    frame.point(farMain, crossEdge),
  ];
}
