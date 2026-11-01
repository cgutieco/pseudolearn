import 'package:flutter/material.dart';
import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/editor_metrics.dart';
import 'class_shapes.dart';
import '../theme/font_role_style.dart';
import '../theme/tokens/typography.dart';

final class ClassRelationPainter {
  final AppSemanticColors colors;

  const ClassRelationPainter(this.colors);

  void paintRelation(Canvas canvas, DiagramEdge edge) {
    if (edge.points.length < 2) return;
    final stroke = _strokeOf(edge);
    canvas.drawPath(_lineOf(edge), stroke);
    _paintHead(canvas, edge, stroke);
    _paintLabel(canvas, edge);
  }

  Paint _strokeOf(DiagramEdge edge) => Paint()
    ..color = edge.isValid ? colors.borders.strong : colors.severities.error.border
    ..strokeWidth = EditorMetricsTokens.flowNodeBorderWidth
    ..style = PaintingStyle.stroke;

  Path _lineOf(DiagramEdge edge) {
    final path = _pathOf(edge);
    final dashed = edge.kind == DiagramEdgeKind.realization ||
        edge.kind == DiagramEdgeKind.usage;
    if (!dashed) return path;
    return ClassShapes.dashed(
      path,
      dash: edge.isValid
          ? ClassDiagramMetrics.dashLength
          : ClassDiagramMetrics.invalidDashLength,
      gap: ClassDiagramMetrics.dashGap,
    );
  }

  Path _pathOf(DiagramEdge edge) {
    final path = Path()..moveTo(edge.points.first.x, edge.points.first.y);
    for (var index = 1; index < edge.points.length; index++) {
      path.lineTo(edge.points[index].x, edge.points[index].y);
    }
    return path;
  }

  void _paintHead(Canvas canvas, DiagramEdge edge, Paint stroke) {
    final from = edge.points[edge.points.length - 2];
    final tip = edge.points.last;
    switch (edge.kind) {
      case DiagramEdgeKind.generalization || DiagramEdgeKind.realization:
        final head = ClassShapes.hollowArrowHead(from, tip);
        canvas.drawPath(head, Paint()..color = colors.surfaces.raised);
        canvas.drawPath(head, stroke);
      case DiagramEdgeKind.usage:
        canvas.drawPath(ClassShapes.openArrowHead(from, tip), stroke);
      default:
        return;
    }
  }

  void _paintLabel(Canvas canvas, DiagramEdge edge) {
    final label = edge.label;
    final anchor = edge.labelAnchor;
    if (label == null || anchor == null) return;
    final painter = TextPainter(
      text: TextSpan(text: label, style: _labelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout();
    final box = Rect.fromCenter(
      center: Offset(anchor.x, anchor.y),
      width: painter.width + ClassDiagramMetrics.boxPadding,
      height: painter.height,
    );
    canvas.drawRect(box, Paint()..color = colors.surfaces.defaultSurface);
    painter.paint(
      canvas,
      Offset(box.center.dx - painter.width / 2, box.top),
    );
  }

  TextStyle get _labelStyle => TextStyle(
        color: colors.text.secondary,
        fontSize: DiagramMetrics.fontSize,
        height: DiagramMetrics.lineHeight / DiagramMetrics.fontSize,
        fontWeight: FontWeight.w500,
      ).inRole(AppFontRole.ui);
}
