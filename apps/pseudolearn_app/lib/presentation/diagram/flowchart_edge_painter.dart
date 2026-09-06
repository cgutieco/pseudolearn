import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/editor_metrics.dart';
import '../theme/font_role_style.dart';
import '../theme/tokens/typography.dart';

final class FlowchartEdgePainter {
  final AppSemanticColors colors;

  const FlowchartEdgePainter(this.colors);

  void paintEdge(Canvas canvas, DiagramEdge edge) {
    if (edge.points.length < 2) return;
    final stroke = Paint()
      ..color = _strokeColorOf(edge.kind)
      ..strokeWidth = EditorMetricsTokens.flowConnectorStroke
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(edge.points.first.x, edge.points.first.y);
    for (var index = 1; index < edge.points.length; index++) {
      path.lineTo(edge.points[index].x, edge.points[index].y);
    }
    canvas.drawPath(path, stroke);
    _paintArrowHead(canvas, edge, stroke.color);
    _paintLabel(canvas, edge);
  }

  Color _strokeColorOf(DiagramEdgeKind kind) =>
      kind == DiagramEdgeKind.loopBack ? colors.borders.focus : colors.borders.strong;

  void _paintArrowHead(Canvas canvas, DiagramEdge edge, Color color) {
    final tip = edge.points.last;
    final previous = edge.points[edge.points.length - 2];
    final angle = math.atan2(tip.y - previous.y, tip.x - previous.x);
    const length = EditorMetricsTokens.flowConnectorArrowLength;
    const halfWidth = EditorMetricsTokens.flowConnectorArrowWidth / 2;
    final base = Offset(
      tip.x - length * math.cos(angle),
      tip.y - length * math.sin(angle),
    );
    final normal = Offset(-math.sin(angle) * halfWidth, math.cos(angle) * halfWidth);
    final head = Path()
      ..moveTo(tip.x, tip.y)
      ..lineTo(base.dx + normal.dx, base.dy + normal.dy)
      ..lineTo(base.dx - normal.dx, base.dy - normal.dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
  }

  void _paintLabel(Canvas canvas, DiagramEdge edge) {
    final label = edge.label;
    final anchor = edge.labelAnchor;
    if (label == null || anchor == null) return;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: colors.text.secondary,
          fontSize: DiagramMetrics.fontSize,
          fontWeight: FontWeight.w600,
        ).inRole(AppFontRole.ui),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final box = Rect.fromCenter(
      center: Offset(anchor.x, anchor.y),
      width: painter.width + DiagramMetrics.edgeLabelGap,
      height: painter.height,
    );
    canvas.drawRect(box, Paint()..color = colors.surfaces.canvas);
    painter.paint(canvas, Offset(box.center.dx - painter.width / 2, box.top));
  }
}
