import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../application/agent/flowchart/flowchart_layout_model.dart';
import '../../../domain/model/agent/flowchart.dart';
import 'reply_metrics.dart';

const double _arrowSpread = 0.45;

void paintFlowchartEdge(Canvas canvas, RoutedEdge routed, Color color) {
  final edge = routed.edge;
  final points = [for (final point in routed.points) Offset(point.x, point.y)];
  if (edge.stroke == FlowchartStroke.invisible || points.length < 2) return;
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = edge.stroke == FlowchartStroke.thick ? ReplyMetrics.diagramThickStroke : ReplyMetrics.diagramStroke;
  for (var index = 1; index < points.length; index += 1) {
    _segment(canvas, from: points[index - 1], to: points[index], paint: paint, dotted: edge.stroke == FlowchartStroke.dotted);
  }
  final fill = Paint()..color = color;
  if (edge.arrowAtEnd) _arrowHead(canvas, from: points[points.length - 2], tip: points.last, fill: fill);
  if (edge.arrowAtStart) _arrowHead(canvas, from: points[1], tip: points.first, fill: fill);
}

void _segment(Canvas canvas, {required Offset from, required Offset to, required Paint paint, required bool dotted}) {
  if (!dotted) {
    canvas.drawLine(from, to, paint);
    return;
  }
  final length = (to - from).distance;
  if (length == 0) return;
  final direction = (to - from) / length;
  const dash = ReplyMetrics.diagramDashLength;
  for (var travelled = 0.0; travelled < length; travelled += dash * 2) {
    final end = math.min(travelled + dash, length);
    canvas.drawLine(from + direction * travelled, from + direction * end, paint);
  }
}

void _arrowHead(Canvas canvas, {required Offset from, required Offset tip, required Paint fill}) {
  final angle = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
  const length = ReplyMetrics.diagramArrowLength;
  Offset wing(double turn) =>
      tip - Offset(math.cos(angle + turn), math.sin(angle + turn)) * length;
  canvas.drawPath(
    Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(wing(_arrowSpread).dx, wing(_arrowSpread).dy)
      ..lineTo(wing(-_arrowSpread).dx, wing(-_arrowSpread).dy)
      ..close(),
    fill,
  );
}
