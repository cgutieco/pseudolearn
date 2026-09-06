import 'dart:math' as math;

import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/class_model.dart';
import 'class_box_sizing.dart';

final class ClassColumnGrid {
  final List<double> _columnWidths;
  final List<double> _columnLefts;
  final Map<ClassBox, int> _boxColumns;

  const ClassColumnGrid._({
    required List<double> columnWidths,
    required List<double> columnLefts,
    required Map<ClassBox, int> boxColumns,
  })  : _columnWidths = columnWidths,
        _columnLefts = columnLefts,
        _boxColumns = boxColumns;

  factory ClassColumnGrid.of({
    required List<List<ClassBox>> levels,
    required Map<ClassBox, ClassBoxSize> sizes,
    required double boxGap,
  }) {
    final maxColumns = _maxColumnsOf(levels);
    if (maxColumns == 0) {
      return const ClassColumnGrid._(
        columnWidths: [],
        columnLefts: [],
        boxColumns: {},
      );
    }
    final boxColumns = <ClassBox, int>{};
    final widths = List<double>.filled(maxColumns, ClassDiagramMetrics.boxMinWidth);
    _populateColumns(
      levels: levels,
      sizes: sizes,
      maxColumns: maxColumns,
      boxColumns: boxColumns,
      widths: widths,
    );
    final lefts = _calculateLefts(widths, boxGap);

    return ClassColumnGrid._(
      columnWidths: List.unmodifiable(widths),
      columnLefts: List.unmodifiable(lefts),
      boxColumns: Map.unmodifiable(boxColumns),
    );
  }

  static int _maxColumnsOf(List<List<ClassBox>> levels) {
    var maxColumns = 0;
    for (final level in levels) {
      maxColumns = math.max(maxColumns, level.length);
    }
    return maxColumns;
  }

  static void _populateColumns({
    required List<List<ClassBox>> levels,
    required Map<ClassBox, ClassBoxSize> sizes,
    required int maxColumns,
    required Map<ClassBox, int> boxColumns,
    required List<double> widths,
  }) {
    for (final level in levels) {
      final startColumn = (maxColumns - level.length) ~/ 2;
      for (var index = 0; index < level.length; index++) {
        final box = level[index];
        final columnIndex = startColumn + index;
        boxColumns[box] = columnIndex;
        final boxWidth = sizes[box]?.width ?? ClassDiagramMetrics.boxMinWidth;
        widths[columnIndex] = math.max(widths[columnIndex], boxWidth);
      }
    }
  }

  static List<double> _calculateLefts(List<double> widths, double boxGap) {
    final lefts = List<double>.filled(widths.length, 0.0);
    var currentLeft = 0.0;
    for (var index = 0; index < widths.length; index++) {
      lefts[index] = currentLeft;
      currentLeft += widths[index] + boxGap;
    }
    return lefts;
  }

  int get columnCount => _columnWidths.length;

  int columnOf(ClassBox box) => _boxColumns[box] ?? 0;

  double columnLeftAt(int columnIndex) =>
      columnIndex >= 0 && columnIndex < _columnLefts.length
          ? _columnLefts[columnIndex]
          : 0.0;

  double columnWidthAt(int columnIndex) =>
      columnIndex >= 0 && columnIndex < _columnWidths.length
          ? _columnWidths[columnIndex]
          : ClassDiagramMetrics.boxMinWidth;

  double get totalWidth {
    if (_columnWidths.isEmpty) return 0.0;
    return _columnLefts.last + _columnWidths.last;
  }
}

