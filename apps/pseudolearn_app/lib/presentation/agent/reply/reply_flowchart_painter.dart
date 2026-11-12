import 'package:material_ui/material_ui.dart';
import '../../../application/agent/flowchart/flowchart_layout_model.dart';
import '../../../domain/model/agent/flowchart.dart';
import 'reply_flowchart_edges.dart';
import 'reply_flowchart_geometry.dart';
import 'reply_flowchart_shapes.dart';
import 'reply_metrics.dart';

final class FlowchartPalette {
  final Color nodeFill;
  final Color nodeStroke;
  final Color edge;
  final Color labelSurface;

  const FlowchartPalette({
    required this.nodeFill,
    required this.nodeStroke,
    required this.edge,
    required this.labelSurface,
  });
}

final class ReplyFlowchartPainter extends CustomPainter {
  final FlowchartLayout layout;
  final FlowchartPalette palette;
  final FlowchartTextStyle text;

  const ReplyFlowchartPainter({required this.layout, required this.palette, required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in layout.edges) {
      paintFlowchartEdge(canvas, edge, palette.edge);
    }
    for (final node in layout.nodes) {
      _paintNode(canvas, node);
    }
    for (final edge in layout.edges) {
      _paintEdgeLabel(canvas, edge);
    }
  }

  void _paintNode(Canvas canvas, PlacedNode placed) {
    final rect = Rect.fromLTWH(placed.left, placed.top, placed.width, placed.height);
    final outline = replyFlowchartOutline(placed.node.shape, rect);
    final stroke = Paint()
      ..color = palette.nodeStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = ReplyMetrics.diagramStroke;
    canvas.drawPath(outline, Paint()..color = palette.nodeFill);
    canvas.drawPath(outline, stroke);
    for (final decoration in replyFlowchartDecorations(placed.node.shape, rect)) {
      canvas.drawPath(decoration, stroke);
    }
    _paintCentered(canvas, text.painterFor(placed.node.label), rect.center);
  }

  void _paintEdgeLabel(Canvas canvas, RoutedEdge routed) {
    if (routed.edge.label.isEmpty || routed.edge.stroke == FlowchartStroke.invisible) return;
    final label = text.painterFor(routed.edge.label);
    final anchor = Offset(routed.labelAnchor.x, routed.labelAnchor.y);
    final background = Rect.fromCenter(
      center: anchor,
      width: label.width + ReplyMetrics.diagramDashLength * 2,
      height: label.height + ReplyMetrics.diagramDashLength,
    );
    canvas.drawRect(background, Paint()..color = palette.labelSurface);
    _paintCentered(canvas, label, anchor);
  }

  void _paintCentered(Canvas canvas, TextPainter painter, Offset center) {
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(ReplyFlowchartPainter oldDelegate) =>
      oldDelegate.layout != layout || oldDelegate.palette != palette || oldDelegate.text != text;
}
