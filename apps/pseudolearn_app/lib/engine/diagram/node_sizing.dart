import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'text_metrics.dart';

final class SizedLabel {
  final List<String> lines;
  final double width;
  final double height;

  const SizedLabel({
    required this.lines,
    required this.width,
    required this.height,
  });
}

final class NodeSizing {
  final TextMetrics _metrics;

  const NodeSizing(this._metrics);

  SizedLabel measure(String text, DiagramShape shape) {
    if (shape == DiagramShape.connector) {
      return const SizedLabel(
        lines: [],
        width: DiagramMetrics.connectorDiameter,
        height: DiagramMetrics.connectorDiameter,
      );
    }
    final lines = _metrics.wrapText(
      text,
      maxUnits: _wrapUnitsFor(shape),
      maxLines: DiagramMetrics.maxTextLines,
    );
    final contentWidth = _widestLine(lines) * DiagramMetrics.fontSize;
    final boxWidth = contentWidth + DiagramMetrics.nodePadding * 2;
    final boxHeight = lines.length * DiagramMetrics.lineHeight + DiagramMetrics.nodePadding * 2;
    return SizedLabel(
      lines: lines,
      width: _widthFor(shape, boxWidth, boxHeight),
      height: _heightFor(shape, boxHeight),
    );
  }

  double _widestLine(List<String> lines) {
    var widest = 0.0;
    for (final line in lines) {
      final units = _metrics.advanceUnits(line);
      if (units > widest) widest = units;
    }
    return widest;
  }

  double _wrapUnitsFor(DiagramShape shape) {
    final available = switch (shape) {
      DiagramShape.decision => DiagramMetrics.nodeMaxWidth * 0.6,
      DiagramShape.preparation => DiagramMetrics.nodeMaxWidth * 0.8,
      _ => DiagramMetrics.nodeMaxWidth,
    };
    return (available - DiagramMetrics.nodePadding * 2) / DiagramMetrics.fontSize;
  }

  double _widthFor(DiagramShape shape, double boxWidth, double boxHeight) {
    final width = switch (shape) {
      DiagramShape.decision => boxWidth * DiagramMetrics.decisionWidthFactor,
      DiagramShape.preparation => boxWidth + boxHeight,
      DiagramShape.inputOutput => boxWidth + DiagramMetrics.inputOutputSkew * 2,
      DiagramShape.subprogram => boxWidth + DiagramMetrics.nodePadding * 2,
      _ => boxWidth,
    };
    return width < DiagramMetrics.nodeMinWidth ? DiagramMetrics.nodeMinWidth : width;
  }

  double _heightFor(DiagramShape shape, double boxHeight) {
    final height = shape == DiagramShape.decision
        ? boxHeight * DiagramMetrics.decisionHeightFactor
        : boxHeight;
    return height < DiagramMetrics.nodeMinHeight ? DiagramMetrics.nodeMinHeight : height;
  }
}
