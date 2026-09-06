import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'diagram_scene_validators.dart';

DiagramNode _frameNode(
        String id, double x, double y, double width, double height) =>
    DiagramNode(
      id: id,
      shape: DiagramShape.classFrame,
      lines: const ['C'],
      x: x,
      y: y,
      width: width,
      height: height,
      nodeId: const ProgramNodeId(1),
    );

DiagramNode _headerNode(
        String id, String text, double x, double y, double width, double height) =>
    DiagramNode(
      id: id,
      shape: DiagramShape.classHeader,
      lines: [text],
      x: x,
      y: y,
      width: width,
      height: height,
      nodeId: const ProgramNodeId(1),
    );

DiagramNode _rowNode(
        String id, String text, double x, double y, double width, double height) =>
    DiagramNode(
      id: id,
      shape: DiagramShape.classRow,
      lines: [text],
      x: x,
      y: y,
      width: width,
      height: height,
      nodeId: const ProgramNodeId(1),
    );

void main() {
  group('DiagramScene Validators', () {
    test('CDL-TEXT-COMPLETE validator detects ellipsized text (negative fixture)', () {
      final sceneWithEllipsis = DiagramScene(
        nodes: [
          _rowNode('r1', '+ method(param: Cadena…', 0, 0, 200, 24),
        ],
        edges: const [],
        width: 200,
        height: 24,
      );

      expect(countEllipsizedTexts(sceneWithEllipsis), greaterThan(0));
    });

    test('CDL-TEXT-INSIDE validator detects text width overflow (negative fixture)', () {
      final sceneWithOverflow = DiagramScene(
        nodes: [
          _headerNode('h1', 'VeryLongClassNameExceedingBoxWidthBounds', 0, 0, 100, 28),
        ],
        edges: const [],
        width: 100,
        height: 28,
      );

      expect(countTextOverflows(sceneWithOverflow), greaterThan(0));
    });

    test('CDL-NO-BOX-CROSS validator detects line crossing frame interior (negative fixture)', () {
      final sceneWithCrossing = DiagramScene(
        nodes: [
          _frameNode('A', 0, 0, 100, 100),
          _frameNode('Intermediate', 150, 0, 100, 100),
          _frameNode('B', 300, 0, 100, 100),
        ],
        edges: const [
          DiagramEdge(
            fromId: 'A',
            toId: 'B',
            points: [
              DiagramPoint(100, 50),
              DiagramPoint(300, 50),
            ],
            kind: DiagramEdgeKind.association,
          ),
        ],
        width: 400,
        height: 100,
      );

      expect(countLineBoxCrossings(sceneWithCrossing), greaterThan(0));
    });

    test('CDL-NO-LABEL-OVERLAP validator detects overlapping labels (negative fixture)', () {
      final sceneWithOverlappingLabels = DiagramScene(
        nodes: [
          _frameNode('A', 0, 0, 100, 100),
          _frameNode('B', 0, 200, 100, 100),
        ],
        edges: [
          const DiagramEdge(
            fromId: 'A',
            toId: 'B',
            points: [DiagramPoint(50, 100), DiagramPoint(50, 200)],
            label: 'propA 1',
            labelAnchor: DiagramPoint(100, 150),
          ),
          const DiagramEdge(
            fromId: 'B',
            toId: 'A',
            points: [DiagramPoint(60, 200), DiagramPoint(60, 100)],
            label: 'propB 1',
            labelAnchor: DiagramPoint(105, 152),
          ),
        ],
        width: 200,
        height: 300,
      );

      expect(countOverlappingLabels(sceneWithOverlappingLabels), greaterThan(0));
      expect(countTotalLabelCollisions(sceneWithOverlappingLabels), greaterThan(0));
    });

    test('CDL-NO-LABEL-OVERLAP validator detects label collision with class frame (negative fixture)', () {
      final sceneWithLabelBoxCollision = DiagramScene(
        nodes: [
          _frameNode('A', 50, 50, 100, 100),
        ],
        edges: [
          const DiagramEdge(
            fromId: 'X',
            toId: 'Y',
            points: [DiagramPoint(0, 0), DiagramPoint(200, 200)],
            label: 'collidingLabel 1',
            labelAnchor: DiagramPoint(100, 100),
          ),
        ],
        width: 200,
        height: 200,
      );

      expect(countTotalLabelCollisions(sceneWithLabelBoxCollision), greaterThan(0));
    });

    test('CDL-NO-COLINEAR validator detects collinear overlapping edges (negative fixture)', () {
      final sceneWithCollinearOverlap = DiagramScene(
        nodes: [
          _frameNode('A', 0, 0, 100, 100),
          _frameNode('B', 0, 200, 100, 100),
        ],
        edges: [
          const DiagramEdge(
            fromId: 'A',
            toId: 'B',
            points: [DiagramPoint(50, 100), DiagramPoint(50, 200)],
            kind: DiagramEdgeKind.association,
          ),
          const DiagramEdge(
            fromId: 'B',
            toId: 'A',
            points: [DiagramPoint(50, 120), DiagramPoint(50, 180)],
            kind: DiagramEdgeKind.association,
          ),
        ],
        width: 200,
        height: 300,
      );

      expect(measureCollinearOverlapPx(sceneWithCollinearOverlap), greaterThan(0.0));
    });

    test('CDL-CROSS-BUDGET counts orthogonal edge intersections (negative fixture)', () {
      const sceneWithCrossingEdges = DiagramScene(
        nodes: [],
        edges: [
          DiagramEdge(
            fromId: 'A',
            toId: 'B',
            points: [DiagramPoint(0, 50), DiagramPoint(100, 50)],
          ),
          DiagramEdge(
            fromId: 'C',
            toId: 'D',
            points: [DiagramPoint(50, 0), DiagramPoint(50, 100)],
          ),
        ],
        width: 100,
        height: 100,
      );

      expect(countEdgeEdgeCrossings(sceneWithCrossingEdges), 1);
    });

    test('CDL-DETERMINISM validator detects differences between scenes (negative fixture)', () {
      final sceneA = DiagramScene(
        nodes: [_frameNode('A', 0, 0, 100, 100)],
        edges: const [],
        width: 100,
        height: 100,
      );
      final sceneB = DiagramScene(
        nodes: [_frameNode('A', 10, 0, 100, 100)],
        edges: const [],
        width: 110,
        height: 100,
      );

      expect(areScenesIdentical(sceneA, sceneB), isFalse);
    });

    test('shared generalization trunk is not counted as collinear overlap', () {
      final sceneWithSharedTrunk = DiagramScene(
        nodes: [
          _frameNode('Sub1', 0, 200, 100, 100),
          _frameNode('Sub2', 150, 200, 100, 100),
          _frameNode('Super', 75, 0, 100, 100),
        ],
        edges: [
          const DiagramEdge(
            fromId: 'Sub1',
            toId: 'Super',
            points: [
              DiagramPoint(50, 200),
              DiagramPoint(50, 150),
              DiagramPoint(125, 150),
              DiagramPoint(125, 100),
            ],
            kind: DiagramEdgeKind.generalization,
          ),
          const DiagramEdge(
            fromId: 'Sub2',
            toId: 'Super',
            points: [
              DiagramPoint(200, 200),
              DiagramPoint(200, 150),
              DiagramPoint(125, 150),
              DiagramPoint(125, 100),
            ],
            kind: DiagramEdgeKind.generalization,
          ),
        ],
        width: 300,
        height: 300,
      );

      expect(
        measureCollinearOverlapPx(sceneWithSharedTrunk,
            allowSharedGeneralizationTrunk: true),
        0.0,
      );
    });
  });
}
