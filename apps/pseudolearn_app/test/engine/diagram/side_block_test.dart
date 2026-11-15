import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/engine/diagram/layout_block.dart';
import 'package:pseudolearn_app/engine/diagram/side_block.dart';

DiagramNode _node(String id, {double width = 100, double height = 40}) =>
    DiagramNode(
      id: id,
      shape: DiagramShape.process,
      lines: [id],
      x: 0,
      y: 0,
      width: width,
      height: height,
    );

void main() {
  group('SideBlock', () {
    test('places the side block to the right and keeps the main flow', () {
      final block = SideBlock.compose(
        main: _node('main'),
        side: LayoutBlock.fromNode(_node('side', height: 80)),
        kind: DiagramEdgeKind.cleanupRegistration,
      );
      final side = block.nodes.last;

      expect(side.x, 100 + DiagramMetrics.gapHorizontal);
      expect(block.width, 200 + DiagramMetrics.gapHorizontal);
      expect(block.height, 80);
      expect(block.spineX, 50);
      expect(block.entryId, 'main');
      expect(block.exitId, 'main');
      expect(block.hasExit, isTrue);
    });

    test('links the main node to the side entry with the given kind', () {
      final block = SideBlock.compose(
        main: _node('main'),
        side: LayoutBlock.fromNode(_node('side')),
        kind: DiagramEdgeKind.propagationExit,
      );
      final link = block.edges.single;

      expect(link.kind, DiagramEdgeKind.propagationExit);
      expect(link.fromId, 'main');
      expect(link.toId, 'side');
      expect(link.points.first.x, 100);
      expect(link.points.last.x, 100 + DiagramMetrics.gapHorizontal);
    });

    test('a side block without entry adds no link', () {
      final block = SideBlock.compose(
        main: _node('main'),
        side: const LayoutBlock.lane(0.0),
        kind: DiagramEdgeKind.cleanupRegistration,
      );

      expect(block.edges, isEmpty);
      expect(block.nodes, hasLength(1));
    });
  });
}
