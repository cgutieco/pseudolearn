import 'package:flutter/material.dart';
import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/editor_metrics.dart';
import 'class_relation_painter.dart';
import '../theme/font_role_style.dart';
import '../theme/tokens/typography.dart';

final class ClassBoxPainter extends CustomPainter {
  final DiagramScene scene;
  final AppSemanticColors colors;

  const ClassBoxPainter({required this.scene, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in scene.nodes) {
      _paintSurface(canvas, node);
    }
    final relations = ClassRelationPainter(colors);
    for (final edge in scene.edges) {
      relations.paintRelation(canvas, edge);
    }
    for (final node in scene.nodes) {
      _paintText(canvas, node);
    }
  }

  @override
  bool shouldRepaint(covariant ClassBoxPainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.colors != colors;

  Paint get _border => Paint()
    ..color = colors.borders.strong
    ..strokeWidth = EditorMetricsTokens.flowNodeBorderWidth
    ..style = PaintingStyle.stroke
    ..isAntiAlias = false;

  void _paintSurface(Canvas canvas, DiagramNode node) {
    if (node.shape == DiagramShape.classRow) return;
    final rect = _rectOf(node);
    canvas.drawRect(rect, Paint()..color = _fillColorOf(node.shape));
    canvas.drawRect(rect, _border);
  }

  Color _fillColorOf(DiagramShape shape) => shape == DiagramShape.classHeader
      ? colors.surfaces.defaultSurface
      : colors.surfaces.raised;

  void _paintText(Canvas canvas, DiagramNode node) {
    if (node.lines.isEmpty) return;
    if (node.shape == DiagramShape.classHeader) {
      _paintHeaderText(canvas, node);
      return;
    }
    _paintRowText(canvas, node);
  }

  void _paintHeaderText(Canvas canvas, DiagramNode node) {
    final rect = _rectOf(node);
    final painter = _layout(
      node.lines.first,
      maxWidth: rect.width - ClassDiagramMetrics.boxPadding * 2,
      align: TextAlign.center,
      weight: FontWeight.w700,
      color: colors.text.primary,
    );
    painter.paint(
      canvas,
      Offset(
        rect.center.dx - painter.width / 2,
        rect.center.dy - painter.height / 2,
      ),
    );
  }

  void _paintRowText(Canvas canvas, DiagramNode node) {
    final rect = _rectOf(node);
    final painter = _layout(
      node.lines.first,
      maxWidth: rect.width - ClassDiagramMetrics.boxPadding * 2,
      align: TextAlign.left,
      weight: FontWeight.w500,
      color: colors.text.primary,
    );
    painter.paint(
      canvas,
      Offset(
        rect.left + ClassDiagramMetrics.boxPadding,
        rect.center.dy - painter.height / 2,
      ),
    );
  }

  TextPainter _layout(
    String text, {
    required double maxWidth,
    required TextAlign align,
    required FontWeight weight,
    required Color color,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: DiagramMetrics.fontSize,
          height: DiagramMetrics.lineHeight / DiagramMetrics.fontSize,
          fontWeight: weight,
        ).inRole(AppFontRole.ui),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
  }

  Rect _rectOf(DiagramNode node) =>
      Rect.fromLTWH(node.x, node.y, node.width, node.height);
}
