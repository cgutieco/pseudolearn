import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_focus_frame.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_viewport.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/component_metrics.dart';

DiagramScene _sceneOf(double width, double height) => DiagramScene(
      nodes: const [],
      edges: const [],
      width: width,
      height: height,
    );

double _scaleOf(Matrix4 matrix) => matrix.getMaxScaleOnAxis();

Offset _pointUnderCamera(Matrix4 matrix, Offset scenePoint, Offset origin) {
  final scale = _scaleOf(matrix);
  final translation = matrix.getTranslation();
  return Offset(
    (scenePoint.dx + origin.dx) * scale + translation.x,
    (scenePoint.dy + origin.dy) * scale + translation.y,
  );
}

void main() {
  group('FlowchartViewport · framing a focused node', () {
    test('places the centre of the node at the centre of the panel', () {
      const viewport = Size(400, 700);
      final flow = FlowchartViewport(
        scene: _sceneOf(1200, 3000),
        viewport: viewport,
      );
      const frame = DiagramFocusFrame(x: 500, y: 1400, width: 200, height: 48);

      final matrix = flow.matrixForFrame(frame);
      final centre = _pointUnderCamera(
        matrix,
        const Offset(600, 1424),
        Offset.zero,
      );

      expect(centre.dx, closeTo(viewport.width / 2, 0.001));
      expect(centre.dy, closeTo(viewport.height / 2, 0.001));
    });

    test('accounts for the scene being centred inside a wider child', () {
      const viewport = Size(900, 700);
      final scene = _sceneOf(300, 400);
      final flow = FlowchartViewport(scene: scene, viewport: viewport);
      const frame = DiagramFocusFrame(x: 100, y: 150, width: 100, height: 40);

      final matrix = flow.matrixForFrame(frame);
      final origin = Offset(
        (flow.childSize.width - scene.width) / 2,
        (flow.childSize.height - scene.height) / 2,
      );
      final centre = _pointUnderCamera(matrix, const Offset(150, 170), origin);

      expect(centre.dx, closeTo(viewport.width / 2, 0.001));
      expect(centre.dy, closeTo(viewport.height / 2, 0.001));
    });

    test('a tiny node in a large panel stops at the assisted zoom ceiling', () {
      final flow = FlowchartViewport(
        scene: _sceneOf(4000, 4000),
        viewport: const Size(1400, 1000),
      );
      const frame = DiagramFocusFrame(x: 100, y: 100, width: 20, height: 20);

      expect(
        _scaleOf(flow.matrixForFrame(frame)),
        closeTo(ComponentMetricsTokens.flowCanvasFocusZoomMax, 0.001),
      );
    });

    test('a node wider than the panel is shrunk to fit it with its margin', () {
      const viewport = Size(400, 700);
      final flow = FlowchartViewport(
        scene: _sceneOf(2000, 2000),
        viewport: viewport,
      );
      const frame = DiagramFocusFrame(x: 0, y: 0, width: 1600, height: 48);

      final scale = _scaleOf(flow.matrixForFrame(frame));

      expect(scale, lessThan(1.0));
      expect(scale, greaterThanOrEqualTo(flow.minScale));
    });

    test('a node taller than the whole panel never goes below the floor', () {
      final flow = FlowchartViewport(
        scene: _sceneOf(400, 40000),
        viewport: const Size(400, 200),
      );
      const frame = DiagramFocusFrame(x: 0, y: 0, width: 200, height: 30000);

      final scale = _scaleOf(flow.matrixForFrame(frame));

      expect(
        scale,
        greaterThanOrEqualTo(ComponentMetricsTokens.flowCanvasZoomFloor),
      );
    });

    test('framing the top node leaves no empty band above it', () {
      final flow = FlowchartViewport(
        scene: _sceneOf(400, 6000),
        viewport: const Size(400, 700),
      );
      const frame = DiagramFocusFrame(x: 100, y: 0, width: 200, height: 48);

      final translation = flow.matrixForFrame(frame).getTranslation();

      expect(translation.y, closeTo(0.0, 0.001));
    });

    test('framing the bottom node leaves no empty band below it', () {
      const viewport = Size(400, 700);
      final scene = _sceneOf(400, 6000);
      final flow = FlowchartViewport(scene: scene, viewport: viewport);
      const frame = DiagramFocusFrame(x: 100, y: 5900, width: 200, height: 100);

      final matrix = flow.matrixForFrame(frame);
      final bottom = scene.height * _scaleOf(matrix) +
          matrix.getTranslation().y;

      expect(bottom, greaterThanOrEqualTo(viewport.height - 0.001));
    });

    test('a panel with no area asks for no movement it cannot compute', () {
      const flow = FlowchartViewport(
        scene: DiagramScene(nodes: [], edges: [], width: 400, height: 600),
        viewport: Size.zero,
      );
      const frame = DiagramFocusFrame(x: 0, y: 0, width: 200, height: 48);

      final scale = _scaleOf(flow.matrixForFrame(frame));

      expect(scale, closeTo(flow.minScale, 0.001));
    });

    test('a frame without area is framed at the ceiling, not at zero', () {
      final flow = FlowchartViewport(
        scene: _sceneOf(400, 600),
        viewport: const Size(400, 700),
      );
      const frame = DiagramFocusFrame(x: 200, y: 300, width: 0, height: 0);

      expect(
        _scaleOf(flow.matrixForFrame(frame)),
        closeTo(ComponentMetricsTokens.flowCanvasFocusZoomMax, 0.001),
      );
    });
  });

  group('FlowchartViewport · fitting and scaling', () {
    test('a scene larger than the panel is fitted entirely inside it', () {
      const viewport = Size(400, 700);
      final scene = _sceneOf(1200, 2100);
      final flow = FlowchartViewport(scene: scene, viewport: viewport);

      final scale = _scaleOf(flow.fitMatrix());

      expect(scene.width * scale, lessThanOrEqualTo(viewport.width + 0.001));
      expect(scene.height * scale, lessThanOrEqualTo(viewport.height + 0.001));
    });

    test('a scene smaller than the panel is not blown up to fill it', () {
      final flow = FlowchartViewport(
        scene: _sceneOf(200, 300),
        viewport: const Size(1200, 900),
      );

      expect(_scaleOf(flow.fitMatrix()), closeTo(1.0, 0.001));
    });

    test('a scene without area is left at its natural scale', () {
      const flow = FlowchartViewport(
        scene: DiagramScene.empty(),
        viewport: Size(400, 700),
      );

      expect(_scaleOf(flow.fitMatrix()), closeTo(1.0, 0.001));
    });

    test('a requested scale above the ceiling stays at the ceiling', () {
      final flow = FlowchartViewport(
        scene: _sceneOf(400, 600),
        viewport: const Size(400, 700),
      );

      expect(
        _scaleOf(flow.matrixForScale(9.0)),
        closeTo(ComponentMetricsTokens.flowCanvasZoomMax, 0.001),
      );
    });

    test('a requested scale below the floor stays at the floor', () {
      final flow = FlowchartViewport(
        scene: _sceneOf(400, 600),
        viewport: const Size(400, 700),
      );

      expect(
        _scaleOf(flow.matrixForScale(0.0)),
        closeTo(ComponentMetricsTokens.flowCanvasZoomMin, 0.001),
      );
    });
  });
}
