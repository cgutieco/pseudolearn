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
    canvas.drawPath(_pathOf(edge), _stroke);
    if (edge.kind == DiagramEdgeKind.generalization) _paintArrow(canvas, edge);
    _paintLabel(canvas, edge);
  }

  Paint get _stroke => Paint()
    ..color = colors.borders.strong
    ..strokeWidth = EditorMetricsTokens.flowNodeBorderWidth
    ..style = PaintingStyle.stroke;

  Path _pathOf(DiagramEdge edge) {
    final path = Path()..moveTo(edge.points.first.x, edge.points.first.y);
    for (var index = 1; index < edge.points.length; index++) {
      path.lineTo(edge.points[index].x, edge.points[index].y);
    }
    return path;
  }

  void _paintArrow(Canvas canvas, DiagramEdge edge) {
    final head = ClassShapes.hollowArrowHead(
      edge.points[edge.points.length - 2],
      edge.points.last,
    );
    canvas.drawPath(head, Paint()..color = colors.surfaces.raised);
    canvas.drawPath(head, _stroke);
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
