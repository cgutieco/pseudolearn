import 'dart:math' as math;

import '../../domain/model/diagram/diagram_metrics.dart';
import 'layout_block.dart';

final class PlacedColumns {
  final List<LayoutBlock> blocks;
  final List<double> spines;
  final double width;
  final double top;
  final double bottom;

  const PlacedColumns({
    required this.blocks,
    required this.spines,
    required this.width,
    required this.top,
    required this.bottom,
  });
}

final class BranchGeometry {
  const BranchGeometry._();

  static PlacedColumns place(
    List<LayoutBlock> columns, {
    required double top,
    required double headerWidth,
    required double minimumSpineSpan,
  }) {
    final gap = _gapBetween(columns, minimumSpineSpan);
    final contentWidth = _contentWidth(columns, gap);
    final width = math.max(contentWidth, headerWidth);
    final offset = (width - contentWidth) / 2;
    final blocks = <LayoutBlock>[];
    var left = offset;
    for (final column in columns) {
      blocks.add(column.translate(left, top));
      left += column.width + gap;
    }
    return PlacedColumns(
      blocks: blocks,
      spines: blocks.map((block) => block.spineX).toList(),
      width: width,
      top: top,
      bottom: top + columns.map((column) => column.height).reduce(math.max),
    );
  }

  static double _gapBetween(List<LayoutBlock> columns, double minimumSpineSpan) {
    if (columns.length < 2) return DiagramMetrics.gapHorizontal;
    final spineSpanAtBaseGap = _contentWidth(columns, DiagramMetrics.gapHorizontal) -
        columns.first.spineX -
        (columns.last.width - columns.last.spineX);
    final deficit = minimumSpineSpan - spineSpanAtBaseGap;
    if (deficit <= 0) return DiagramMetrics.gapHorizontal;
    return DiagramMetrics.gapHorizontal + deficit / (columns.length - 1);
  }

  static double _contentWidth(List<LayoutBlock> columns, double gap) {
    final columnsWidth = columns.fold(0.0, (total, column) => total + column.width);
    return columnsWidth + gap * (columns.length - 1);
  }
}
