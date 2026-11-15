import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_shapes.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

const AppSemanticColors _colors = AppSemanticColors.light();

DiagramScene _sceneWith(DiagramEdgeKind kind) => DiagramScene(
  nodes: const [],
  edges: [
    DiagramEdge(
      fromId: 'a',
      toId: 'b',
      kind: kind,
      points: const [DiagramPoint(10, 10), DiagramPoint(10, 150)],
    ),
  ],
  width: 200,
  height: 200,
);

Future<void> _pump(WidgetTester tester, DiagramEdgeKind kind) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomPaint(
          size: const Size(200, 200),
          painter: FlowchartPainter(scene: _sceneWith(kind), colors: _colors),
        ),
      ),
    );

void main() {
  group('flowchart exit edges', () {
    testWidgets('a break exit uses the focus color', (tester) async {
      await _pump(tester, DiagramEdgeKind.breakExit);

      expect(
        find.byType(CustomPaint).first,
        paints..path(color: _colors.borders.focus),
      );
    });

    testWidgets('a propagation exit uses the focus color', (tester) async {
      await _pump(tester, DiagramEdgeKind.propagationExit);

      expect(
        find.byType(CustomPaint).first,
        paints..path(color: _colors.borders.focus),
      );
    });

    testWidgets('an ordinary edge keeps the strong color', (tester) async {
      await _pump(tester, DiagramEdgeKind.normal);

      expect(
        find.byType(CustomPaint).first,
        isNot(paints..path(color: _colors.borders.focus)),
      );
    });

    testWidgets('a cleanup registration paints a dashed line', (tester) async {
      await _pump(tester, DiagramEdgeKind.cleanupRegistration);

      expect(
        find.byType(CustomPaint).first,
        paints..something(
          (method, arguments) =>
              method == #drawPath &&
              (arguments.first as Path).computeMetrics().length > 1,
        ),
      );
    });
  });

  test('a labelled exit connector is an oval like the plain connector', () {
    const rect = Rect.fromLTWH(0, 0, 120, 48);
    final outline = FlowchartShapes.outlineOf(DiagramShape.exitConnector, rect);

    expect(outline.contains(rect.center), isTrue);
    expect(outline.contains(const Offset(1, 1)), isFalse);
  });
}
