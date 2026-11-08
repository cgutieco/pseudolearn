import 'package:flutter/material.dart';
import '../../../application/agent/flowchart/flowchart_layout.dart';
import '../../../application/agent/flowchart/flowchart_layout_model.dart';
import '../../../domain/model/agent/flowchart.dart';
import '../../../domain/model/diagram/diagram_metrics.dart';
import 'reply_metrics.dart';

const double _diamondGrowth = 1.5;
const double _hexagonGrowth = 1.0;

final class FlowchartTextStyle {
  final TextStyle style;
  final TextScaler scaler;
  final TextDirection direction;

  const FlowchartTextStyle({required this.style, required this.scaler, required this.direction});

  TextPainter painterFor(String text) => TextPainter(
    text: TextSpan(text: text, style: style),
    textAlign: TextAlign.center,
    textDirection: direction,
    textScaler: scaler,
  )..layout(maxWidth: ReplyMetrics.diagramLabelMaxWidth);
}

FlowchartLayout measuredFlowchartLayout(Flowchart chart, FlowchartTextStyle text) {
  var labelThickness = 0.0;
  final horizontal = chart.direction == FlowchartDirection.right || chart.direction == FlowchartDirection.left;
  for (final edge in chart.edges) {
    if (edge.label.isEmpty) continue;
    final label = text.painterFor(edge.label);
    final thickness = horizontal ? label.width : label.height;
    if (thickness > labelThickness) labelThickness = thickness;
  }
  return layoutFlowchart(
    chart,
    extents: {for (final node in chart.nodes) node.id: _extentOf(node, text.painterFor(node.label))},
    spacing: FlowchartSpacing(
      rankGap: ReplyMetrics.diagramRankGap + labelThickness,
      nodeGap: ReplyMetrics.diagramNodeGap,
      margin: ReplyMetrics.diagramMargin,
    ),
  );
}

NodeExtent _extentOf(FlowchartNode node, TextPainter label) {
  const padding = DiagramMetrics.nodePadding;
  final width = label.width + padding * 2;
  final height = label.height + padding * 1.5;
  return switch (node.shape) {
    FlowchartShape.diamond => NodeExtent(width: width * _diamondGrowth, height: height * _diamondGrowth),
    FlowchartShape.circle => _square(width > height ? width : height),
    FlowchartShape.hexagon => NodeExtent(width: width + height * _hexagonGrowth, height: height),
    FlowchartShape.parallelogram || FlowchartShape.trapezoid => NodeExtent(
      width: _atLeast(width) + DiagramMetrics.inputOutputSkew * 2,
      height: height,
    ),
    _ => NodeExtent(width: _atLeast(width), height: height),
  };
}

NodeExtent _square(double side) => NodeExtent(width: side, height: side);

double _atLeast(double width) =>
    width < ReplyMetrics.diagramNodeMinWidth ? ReplyMetrics.diagramNodeMinWidth : width;
