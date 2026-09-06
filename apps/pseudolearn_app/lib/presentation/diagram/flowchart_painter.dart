import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/editor_metrics.dart';
import 'flowchart_edge_painter.dart';
import 'flowchart_shapes.dart';
import '../theme/font_role_style.dart';
import '../theme/tokens/typography.dart';

final class FlowchartPainter extends CustomPainter {
  final DiagramScene scene;
  final AppSemanticColors colors;

  const FlowchartPainter({
    required this.scene,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final edgePainter = FlowchartEdgePainter(colors);
    for (final edge in scene.edges) {
      edgePainter.paintEdge(canvas, edge);
    }
    for (final node in scene.nodes) {
      _paintNode(canvas, node);
    }
  }

  @override
  bool shouldRepaint(covariant FlowchartPainter oldDelegate) {
    return oldDelegate.scene != scene || oldDelegate.colors != colors;
  }

  void _paintNode(Canvas canvas, DiagramNode node) {
    final rect = Rect.fromLTWH(node.x, node.y, node.width, node.height);
    final fill = Paint()
      ..color = node.shape == DiagramShape.connector
          ? colors.borders.strong
          : colors.surfaces.raised
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = colors.borders.strong
      ..strokeWidth = EditorMetricsTokens.flowNodeBorderWidth
      ..style = PaintingStyle.stroke;
    final outline = FlowchartShapes.outlineOf(node.shape, rect);
    canvas.drawPath(outline, fill);
    canvas.drawPath(outline, border);
    for (final decoration in FlowchartShapes.decorationsOf(node.shape, rect)) {
      canvas.drawPath(decoration, border);
    }
    _paintLabel(canvas, node, rect);
  }

  void _paintLabel(Canvas canvas, DiagramNode node, Rect rect) {
    if (node.lines.isEmpty) return;
    final style = TextStyle(
      color: colors.text.primary,
      fontSize: DiagramMetrics.fontSize,
      height: DiagramMetrics.lineHeight / DiagramMetrics.fontSize,
      fontWeight: FontWeight.w500,
    ).inRole(AppFontRole.ui);
    final painter = TextPainter(
      text: TextSpan(text: node.lines.join('\n'), style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: DiagramMetrics.maxTextLines,
      ellipsis: '…',
    )..layout(maxWidth: rect.width - DiagramMetrics.nodePadding);
    painter.paint(
      canvas,
      Offset(
        rect.center.dx - painter.width / 2,
        rect.center.dy - painter.height / 2,
      ),
    );
  }
}
