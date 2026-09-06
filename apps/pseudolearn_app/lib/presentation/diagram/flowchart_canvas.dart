import 'package:flutter/material.dart';
import '../../application/diagram/diagram_state.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/component_metrics.dart';
import 'class_execution_overlay_painter.dart';
import 'diagram_structure_painter.dart';
import 'execution_overlay_painter.dart';
import 'flowchart_viewport.dart';

final class FlowchartCanvas extends StatelessWidget {
  final TransformationController controller;
  final DiagramState state;
  final ExecutionFocus? focus;
  final FlowchartViewport flowViewport;
  final VoidCallback? onInteractionStart;

  const FlowchartCanvas({
    super.key,
    required this.controller,
    required this.state,
    required this.focus,
    required this.flowViewport,
    this.onInteractionStart,
  });

  @override
  Widget build(BuildContext context) {
    final childSize = flowViewport.childSize;
    final interactionStart = onInteractionStart;

    return InteractiveViewer(
      constrained: false,
      transformationController: controller,
      boundaryMargin: const EdgeInsets.all(
        ComponentMetricsTokens.flowCanvasPanMargin,
      ),
      minScale: flowViewport.minScale,
      maxScale: ComponentMetricsTokens.flowCanvasZoomMax,
      onInteractionStart:
          interactionStart == null ? null : (_) => interactionStart(),
      child: SizedBox(
        width: childSize.width,
        height: childSize.height,
        child: Center(child: _DiagramLayers(state: state, focus: focus)),
      ),
    );
  }
}

CustomPainter _overlayPainterFor(
  DiagramState state,
  ExecutionFocus? focus,
  AppSemanticColors colors,
) {
  return switch (state.notation) {
    DiagramNotation.flowchart || DiagramNotation.structogram =>
      ExecutionOverlayPainter(scene: state.scene, focus: focus, colors: colors),
    DiagramNotation.classDiagram => ClassExecutionOverlayPainter(
        scene: state.scene,
        memberNodeId: state.focusedMemberNodeId,
        colors: colors,
      ),
  };
}

final class _DiagramLayers extends StatelessWidget {
  final DiagramState state;
  final ExecutionFocus? focus;

  const _DiagramLayers({required this.state, required this.focus});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final scene = state.scene;

    return RepaintBoundary(
      child: SizedBox(
        width: scene.width,
        height: scene.height,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(scene.width, scene.height),
              painter: structurePainterFor(state.notation, scene, theme.colors),
            ),
            CustomPaint(
              size: Size(scene.width, scene.height),
              painter: _overlayPainterFor(state, focus, theme.colors),
            ),
          ],
        ),
      ),
    );
  }
}
