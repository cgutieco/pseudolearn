
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/presentation/diagram/class_box_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/class_shapes.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

DiagramScene _sceneWith(DiagramEdge edge) => DiagramScene(
  nodes: const [],
  edges: [edge],
  width: 200,
  height: 200,
);

DiagramEdge _edge(DiagramEdgeKind kind, {List<String> diagnostics = const []}) =>
    DiagramEdge(
      fromId: 'box1',
      toId: 'box0',
      points: const [DiagramPoint(50, 180), DiagramPoint(50, 20)],
      kind: kind,
      diagnostics: diagnostics,
    );

void main() {
  group('ClassShapes', () {
    test('the hollow head points to the tip with a base behind it', () {
      final head = ClassShapes.hollowArrowHead(
        const DiagramPoint(50, 180),
        const DiagramPoint(50, 20),
      ).getBounds();

      expect(head.top, 20);
      expect(head.bottom, closeTo(20 + ClassDiagramMetrics.arrowSize, 0.001));
      expect(head.width, closeTo(ClassDiagramMetrics.arrowSize, 0.001));
    });

    test('the open head leaves the base closed', () {
      final open = ClassShapes.openArrowHead(
        const DiagramPoint(50, 180),
        const DiagramPoint(50, 20),
      );
      final closed = ClassShapes.hollowArrowHead(
        const DiagramPoint(50, 180),
        const DiagramPoint(50, 20),
      );

      expect(open.getBounds(), closed.getBounds());
      expect(open.computeMetrics().first.isClosed, isFalse);
      expect(closed.computeMetrics().first.isClosed, isTrue);
    });

    test('dashing splits a line into separated segments', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(0, 100);

      final dashed = ClassShapes.dashed(path, dash: 8, gap: 4);

      expect(dashed.computeMetrics().length, 9);
      final covered = dashed.computeMetrics().fold<double>(
        0,
        (sum, metric) => sum + metric.length,
      );
      expect(covered, lessThan(100));
    });

    test('a degenerate path produces no dashes', () {
      expect(
        ClassShapes.dashed(Path(), dash: 8, gap: 4).computeMetrics(),
        isEmpty,
      );
    });
  });

  group('ClassBoxPainter relation styles', () {
    const colors = AppSemanticColors.light();

    Future<void> pumpScene(WidgetTester tester, DiagramScene scene) =>
        tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: ClassBoxPainter(scene: scene, colors: colors),
            ),
          ),
        );

    testWidgets('a valid realization paints the strong border color', (tester) async {
      await pumpScene(tester, _sceneWith(_edge(DiagramEdgeKind.realization)));

      expect(
        find.byType(CustomPaint).first,
        paints
          ..path(color: colors.borders.strong)
          ..path(color: colors.surfaces.raised)
          ..path(color: colors.borders.strong),
      );
    });

    testWidgets('an invalid realization paints the error color', (tester) async {
      await pumpScene(
        tester,
        _sceneWith(
          _edge(DiagramEdgeKind.realization, diagnostics: const ['unknownInterface']),
        ),
      );

      expect(
        find.byType(CustomPaint).first,
        paints..path(color: colors.severities.error.border),
      );
    });

    testWidgets('a usage relation has no filled head', (tester) async {
      await pumpScene(tester, _sceneWith(_edge(DiagramEdgeKind.usage)));

      expect(
        find.byType(CustomPaint).first,
        isNot(paints..path(color: colors.surfaces.raised)),
      );
    });
  });
}
