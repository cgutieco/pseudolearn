import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import '../../domain/model/diagram/diagram_focus_frame.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/component_metrics.dart';

final class FlowchartViewport {
  final DiagramScene scene;
  final Size viewport;

  const FlowchartViewport({required this.scene, required this.viewport});

  Size get childSize => Size(_childWidth, _childHeight);

  double get minScale {
    final requiredToFit = _unclampedFitScale;
    return math
        .min(ComponentMetricsTokens.flowCanvasZoomMin, requiredToFit)
        .clamp(
          ComponentMetricsTokens.flowCanvasZoomFloor,
          ComponentMetricsTokens.flowCanvasZoomMin,
        );
  }

  Matrix4 fitMatrix() {
    final capped = math.min(_unclampedFitScale, 1.0);
    final scale = capped.clamp(
      minScale,
      ComponentMetricsTokens.flowCanvasZoomMax,
    );
    return matrixForScale(scale);
  }

  Matrix4 matrixForScale(double scale) {
    final clamped = scale.clamp(
      minScale,
      ComponentMetricsTokens.flowCanvasZoomMax,
    );
    return _matrixOf(clamped, _centeredTranslation(clamped));
  }

  Matrix4 matrixForFrame(DiagramFocusFrame frame) {
    final scale = _scaleForFrame(frame);
    final target = Offset(
      _sceneOrigin.dx + frame.centerX,
      _sceneOrigin.dy + frame.centerY,
    );
    final centering = Offset(
      viewport.width / 2 - target.dx * scale,
      viewport.height / 2 - target.dy * scale,
    );
    return _matrixOf(scale, _boundedTranslation(scale, centering));
  }

  double get _unclampedFitScale {
    if (scene.width <= 0 || scene.height <= 0 || viewport.isEmpty) return 1.0;
    return math.min(
      viewport.width / scene.width,
      viewport.height / scene.height,
    );
  }

  double get _childWidth => math.max(scene.width, viewport.width);

  double get _childHeight => math.max(scene.height, viewport.height);

  Offset get _sceneOrigin => Offset(
        (_childWidth - scene.width) / 2,
        (_childHeight - scene.height) / 2,
      );

  double _scaleForFrame(DiagramFocusFrame frame) {
    const padding = ComponentMetricsTokens.flowCanvasFocusPadding;
    final width = frame.width + padding * 2;
    final height = frame.height + padding * 2;
    if (width <= 0 || height <= 0 || viewport.isEmpty) return minScale;
    final fitting = math.min(
      viewport.width / width,
      viewport.height / height,
    );
    return fitting.clamp(
      minScale,
      ComponentMetricsTokens.flowCanvasFocusZoomMax,
    );
  }

  Offset _centeredTranslation(double scale) => Offset(
        math.max(0.0, (viewport.width - _childWidth * scale) / 2),
        math.max(0.0, (viewport.height - _childHeight * scale) / 2),
      );

  Offset _boundedTranslation(double scale, Offset desired) => Offset(
        _boundedAxis(desired.dx, viewport.width, _childWidth * scale),
        _boundedAxis(desired.dy, viewport.height, _childHeight * scale),
      );

  double _boundedAxis(double desired, double available, double occupied) {
    if (occupied <= available) return (available - occupied) / 2;
    return desired.clamp(available - occupied, 0.0);
  }

  Matrix4 _matrixOf(double scale, Offset translation) => Matrix4.identity()
    ..translateByDouble(translation.dx, translation.dy, 0.0, 1.0)
    ..scaleByDouble(scale, scale, scale, 1.0);
}
