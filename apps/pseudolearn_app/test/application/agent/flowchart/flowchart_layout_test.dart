import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/flowchart/flowchart_layout.dart';
import 'package:pseudolearn_app/application/agent/flowchart/flowchart_layout_model.dart';
import 'package:pseudolearn_app/domain/model/agent/flowchart.dart';

const FlowchartSpacing _spacing = FlowchartSpacing(rankGap: 40, nodeGap: 20, margin: 10);

Flowchart _chart(List<String> ids, List<(String, String)> links, {FlowchartDirection direction = FlowchartDirection.down}) =>
    Flowchart(
      direction: direction,
      nodes: [for (final id in ids) FlowchartNode(id: id, label: id)],
      edges: [for (final (from, to) in links) FlowchartEdge(from: from, to: to)],
    );

FlowchartLayout _layout(Flowchart chart) => layoutFlowchart(
  chart,
  extents: {for (final node in chart.nodes) node.id: const NodeExtent(width: 60, height: 30)},
  spacing: _spacing,
);

PlacedNode _placed(FlowchartLayout layout, String id) => layout.nodes.firstWhere((placed) => placed.node.id == id);

bool _overlap(PlacedNode a, PlacedNode b) =>
    a.left < b.left + b.width && b.left < a.left + a.width && a.top < b.top + b.height && b.top < a.top + a.height;

void main() {
  test('a downward chain places every node below its predecessor', () {
    final layout = _layout(_chart(['A', 'B', 'C'], [('A', 'B'), ('B', 'C')]));
    expect(_placed(layout, 'B').top, greaterThan(_placed(layout, 'A').top + 30));
    expect(_placed(layout, 'C').top, greaterThan(_placed(layout, 'B').top + 30));
    expect(layout.height, closeTo(10 + 30 * 3 + 40 * 2 + 10, 0.001));
  });

  test('siblings share a rank without overlapping', () {
    final layout = _layout(_chart(['A', 'B', 'C', 'D'], [('A', 'B'), ('A', 'C'), ('A', 'D')]));
    final siblings = [for (final id in ['B', 'C', 'D']) _placed(layout, id)];
    expect(siblings.map((node) => node.top).toSet(), hasLength(1));
    for (var first = 0; first < siblings.length; first += 1) {
      for (var second = first + 1; second < siblings.length; second += 1) {
        expect(_overlap(siblings[first], siblings[second]), isFalse);
      }
    }
    expect(layout.nodes.every((node) => node.left >= 10 && node.left + node.width <= layout.width), isTrue);
  });

  test('a node with one parent is centred under it', () {
    final layout = _layout(_chart(['A', 'B', 'C', 'D'], [('A', 'B'), ('B', 'C'), ('B', 'D')]));
    final parent = _placed(layout, 'B').center.x;
    final children = (_placed(layout, 'C').center.x + _placed(layout, 'D').center.x) / 2;
    expect(parent, closeTo(children, 0.001));
    expect(_placed(layout, 'A').center.x, closeTo(parent, 0.001));
  });

  test('a source feeding a deep node is pulled next to it', () {
    final layout = _layout(_chart(['A', 'B', 'C', 'G'], [('A', 'B'), ('B', 'C'), ('G', 'C')]));
    expect(_placed(layout, 'G').top, _placed(layout, 'B').top);
  });

  test('long edges bend through intermediate ranks and end on the target', () {
    final layout = _layout(_chart(['A', 'B', 'C'], [('A', 'B'), ('B', 'C'), ('A', 'C')]));
    final long = layout.edges.firstWhere((routed) => routed.edge.from == 'A' && routed.edge.to == 'C');
    expect(long.points, hasLength(3));
    final target = _placed(layout, 'C');
    expect(long.points.last.y, target.top);
    expect(long.points.first.y, _placed(layout, 'A').top + 30);
  });

  test('cycles are laid out and the back edge still points to its target', () {
    final layout = _layout(_chart(['A', 'B'], [('A', 'B'), ('B', 'A')]));
    final back = layout.edges.firstWhere((routed) => routed.edge.from == 'B');
    expect(back.points.last.y, lessThan(back.points.first.y));
    expect(_placed(layout, 'A').top, lessThan(_placed(layout, 'B').top));
  });

  test('a self loop is routed beside its node', () {
    final layout = _layout(_chart(['A'], [('A', 'A')]));
    final loop = layout.edges.single;
    expect(loop.points, hasLength(4));
    expect(loop.points[1].x, greaterThan(_placed(layout, 'A').left + 60));
  });

  test('horizontal and reversed directions swap and mirror the axes', () {
    final right = _layout(_chart(['A', 'B'], [('A', 'B')], direction: FlowchartDirection.right));
    expect(_placed(right, 'B').left, greaterThan(_placed(right, 'A').left));
    expect(_placed(right, 'A').width, 60);
    final left = _layout(_chart(['A', 'B'], [('A', 'B')], direction: FlowchartDirection.left));
    expect(_placed(left, 'B').left, lessThan(_placed(left, 'A').left));
    final up = _layout(_chart(['A', 'B'], [('A', 'B')], direction: FlowchartDirection.up));
    expect(_placed(up, 'B').top, lessThan(_placed(up, 'A').top));
  });

  test('an empty chart has no size and edges to unknown nodes are ignored', () {
    final empty = _layout(_chart([], []));
    expect(empty.width, 0);
    expect(empty.nodes, isEmpty);
    final dangling = _layout(_chart(['A'], [('A', 'Z')]));
    expect(dangling.edges, isEmpty);
    expect(dangling.nodes.single.left, 10);
  });

  test('the label anchor sits on the middle segment, nearer its end', () {
    const routed = RoutedEdge(
      edge: FlowchartEdge(from: 'A', to: 'B'),
      points: [LayoutPoint(0, 0), LayoutPoint(0, 10)],
    );
    expect(routed.labelAnchor.y, closeTo(6, 0.001));
    expect(const RoutedEdge(edge: FlowchartEdge(from: 'A', to: 'B'), points: []).labelAnchor.x, 0);
  });
}
