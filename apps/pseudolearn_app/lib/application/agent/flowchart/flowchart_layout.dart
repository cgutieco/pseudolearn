import '../../../domain/model/agent/flowchart.dart';
import 'flowchart_layering.dart';
import 'flowchart_layout_model.dart';
import 'flowchart_ordering.dart';
import 'flowchart_placement.dart';
import 'flowchart_routing.dart';

FlowchartLayout layoutFlowchart(
  Flowchart chart, {
  required Map<String, NodeExtent> extents,
  required FlowchartSpacing spacing,
}) {
  if (chart.nodes.isEmpty) return const FlowchartLayout(nodes: [], edges: [], width: 0, height: 0);
  final graph = layeredGraphOf(chart);
  final horizontal = chart.direction == FlowchartDirection.right || chart.direction == FlowchartDirection.left;
  NodeExtent axisExtent(String id) {
    final extent = extents[id] ?? NodeExtent.none;
    return horizontal ? NodeExtent(width: extent.height, height: extent.width) : extent;
  }
  final placement = placeOnAxes(layers: orderedLayers(graph), graph: graph, extentOf: axisExtent, spacing: spacing);
  final frame = AxisFrame(direction: chart.direction, mainExtent: placement.mainExtent);
  return FlowchartLayout(
    nodes: [for (final node in chart.nodes) _placed(node, placement.boxes[node.id]!, frame)],
    edges: routedEdges(chart: chart, graph: graph, placement: placement, frame: frame, spacing: spacing),
    width: horizontal ? placement.mainExtent : placement.crossExtent,
    height: horizontal ? placement.crossExtent : placement.mainExtent,
  );
}

PlacedNode _placed(FlowchartNode node, AxisBox box, AxisFrame frame) {
  final first = frame.point(box.mainStart, box.crossCenter - box.crossSize / 2);
  final second = frame.point(box.mainEnd, box.crossCenter + box.crossSize / 2);
  return PlacedNode(
    node: node,
    left: first.x < second.x ? first.x : second.x,
    top: first.y < second.y ? first.y : second.y,
    width: (second.x - first.x).abs(),
    height: (second.y - first.y).abs(),
  );
}
