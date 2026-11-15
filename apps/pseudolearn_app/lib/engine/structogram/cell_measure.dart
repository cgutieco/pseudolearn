import 'dart:math' as math;

import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/structogram_metrics.dart';
import '../diagram/text_metrics.dart';
import 'structogram_cell.dart';

final class MeasuredCell {
  final StructogramCell cell;
  final double minWidth;
  final double minHeight;
  final double headerHeight;
  final List<MeasuredCell> children;

  const MeasuredCell({
    required this.cell,
    required this.minWidth,
    required this.minHeight,
    required this.headerHeight,
    required this.children,
  });
}

final class CellMeasure {
  final TextMetrics _text;

  const CellMeasure([this._text = const TextMetrics()]);

  MeasuredCell measure(StructogramCell cell) {
    return switch (cell) {
      StructogramLeaf() => _measureLeaf(cell),
      StructogramStack() => _measureStack(cell),
      StructogramBranch() => _measureBranch(cell),
      StructogramLoop() => _measureLoop(cell),
    };
  }

  double textWidth(List<String> lines) {
    var widest = 0.0;
    for (final line in lines) {
      final units = _text.advanceUnits(line);
      if (units > widest) widest = units;
    }
    return widest * DiagramMetrics.fontSize + StructogramMetrics.cellPadding * 2;
  }

  double textHeight(List<String> lines) {
    final content =
        lines.length * DiagramMetrics.lineHeight + StructogramMetrics.cellPadding * 2;
    return math.max(content, StructogramMetrics.cellMinHeight);
  }

  MeasuredCell _measureLeaf(StructogramLeaf leaf) => MeasuredCell(
        cell: leaf,
        minWidth: math.max(
          StructogramMetrics.cellMinWidth,
          textWidth(leaf.lines) + markerWidthOf(leaf.kind),
        ),
        minHeight: textHeight(leaf.lines),
        headerHeight: 0.0,
        children: const [],
      );

  static double markerWidthOf(StructogramLeafKind kind) {
    return switch (kind) {
      StructogramLeafKind.exit =>
        StructogramMetrics.exitMarkerSize + StructogramMetrics.cellPadding,
      StructogramLeafKind.call => StructogramMetrics.callBarInset * 2,
      StructogramLeafKind.process || StructogramLeafKind.empty => 0.0,
    };
  }

  MeasuredCell _measureStack(StructogramStack stack) {
    final children = [for (final child in stack.children) measure(child)];
    var width = StructogramMetrics.cellMinWidth;
    var height = 0.0;
    for (final child in children) {
      width = math.max(width, child.minWidth);
      height += child.minHeight;
    }
    return MeasuredCell(
      cell: stack,
      minWidth: width,
      minHeight: math.max(height, StructogramMetrics.cellMinHeight),
      headerHeight: 0.0,
      children: children,
    );
  }

  MeasuredCell _measureBranch(StructogramBranch branch) {
    final columns = [for (final column in branch.columns) measure(column.body)];
    final header = textHeight(branch.headerLines) + StructogramMetrics.branchLabelBand;
    var columnsWidth = 0.0;
    var columnsHeight = 0.0;
    for (final column in columns) {
      columnsWidth += column.minWidth;
      columnsHeight = math.max(columnsHeight, column.minHeight);
    }
    return MeasuredCell(
      cell: branch,
      minWidth: math.max(textWidth(branch.headerLines), columnsWidth),
      minHeight: header + columnsHeight,
      headerHeight: header,
      children: columns,
    );
  }

  MeasuredCell _measureLoop(StructogramLoop loop) {
    final body = measure(loop.body);
    final header = textHeight(loop.headerLines);
    return MeasuredCell(
      cell: loop,
      minWidth: math.max(
        textWidth(loop.headerLines),
        body.minWidth + StructogramMetrics.loopIndent,
      ),
      minHeight: header + body.minHeight,
      headerHeight: header,
      children: [body],
    );
  }
}
