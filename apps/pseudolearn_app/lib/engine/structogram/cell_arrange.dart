import 'dart:math' as math;

import '../../domain/model/diagram/structogram_metrics.dart';
import 'cell_measure.dart';
import 'structogram_cell.dart';

final class PlacedCell {
  final StructogramCell cell;
  final double left;
  final double top;
  final double width;
  final double height;
  final double headerHeight;
  final List<PlacedCell> children;

  const PlacedCell({
    required this.cell,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.headerHeight,
    required this.children,
  });

  double get right => left + width;

  double get bottom => top + height;
}

final class _CellFrame {
  final double left;
  final double top;
  final double width;
  final double height;

  const _CellFrame({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

final class CellArrange {
  const CellArrange();

  PlacedCell arrange(
    MeasuredCell measured, {
    double left = 0.0,
    double top = 0.0,
    double? width,
    double? height,
  }) {
    final frame = _CellFrame(
      left: left,
      top: top,
      width: math.max(width ?? measured.minWidth, measured.minWidth),
      height: math.max(height ?? measured.minHeight, measured.minHeight),
    );
    return switch (measured.cell) {
      StructogramLeaf() => _place(measured, frame, const []),
      StructogramStack() => _placeStack(measured, frame),
      StructogramBranch() => _placeBranch(measured, frame),
      StructogramLoop() => _placeLoop(measured, frame),
    };
  }

  PlacedCell _place(
    MeasuredCell measured,
    _CellFrame frame,
    List<PlacedCell> children,
  ) =>
      PlacedCell(
        cell: measured.cell,
        left: frame.left,
        top: frame.top,
        width: frame.width,
        height: frame.height,
        headerHeight: measured.headerHeight,
        children: children,
      );

  PlacedCell _placeStack(MeasuredCell measured, _CellFrame frame) {
    final spare = frame.height - measured.minHeight;
    final children = <PlacedCell>[];
    var top = frame.top;
    for (var index = 0; index < measured.children.length; index++) {
      final child = measured.children[index];
      final isLast = index == measured.children.length - 1;
      final height = isLast ? child.minHeight + spare : child.minHeight;
      children.add(arrange(
        child,
        left: frame.left,
        top: top,
        width: frame.width,
        height: height,
      ));
      top += height;
    }
    return _place(measured, frame, children);
  }

  PlacedCell _placeBranch(MeasuredCell measured, _CellFrame frame) {
    final top = frame.top + measured.headerHeight;
    final height = frame.height - measured.headerHeight;
    final widths = _shareWidth(measured.children, frame.width);
    final children = <PlacedCell>[];
    var left = frame.left;
    for (var index = 0; index < measured.children.length; index++) {
      children.add(arrange(
        measured.children[index],
        left: left,
        top: top,
        width: widths[index],
        height: height,
      ));
      left += widths[index];
    }
    return _place(measured, frame, children);
  }

  PlacedCell _placeLoop(MeasuredCell measured, _CellFrame frame) {
    final loop = measured.cell as StructogramLoop;
    final bodyHeight = frame.height - measured.headerHeight;
    final bodyTop = loop.position == StructogramLoopPosition.header
        ? frame.top + measured.headerHeight
        : frame.top;
    final body = arrange(
      measured.children.first,
      left: frame.left + StructogramMetrics.loopIndent,
      top: bodyTop,
      width: frame.width - StructogramMetrics.loopIndent,
      height: bodyHeight,
    );
    return _place(measured, frame, [body]);
  }

  List<double> _shareWidth(List<MeasuredCell> columns, double available) {
    var demanded = 0.0;
    for (final column in columns) {
      demanded += column.minWidth;
    }
    final spare = available - demanded;
    final widths = <double>[];
    var assigned = 0.0;
    for (var index = 0; index < columns.length; index++) {
      final isLast = index == columns.length - 1;
      final width = isLast
          ? available - assigned
          : columns[index].minWidth + spare * (columns[index].minWidth / demanded);
      widths.add(width);
      assigned += width;
    }
    return widths;
  }
}
