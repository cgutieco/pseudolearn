import 'dart:math' as math;

import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/class_model.dart';
import 'class_box_sizing.dart';
import 'class_column_grid.dart';
import 'inheritance_levels.dart';

final class PlacedClassBox {
  final ClassBox box;
  final ClassBoxSize size;
  final double left;
  final double top;
  final int index;
  final int columnIndex;
  final int levelIndex;

  const PlacedClassBox({
    required this.box,
    required this.size,
    required this.left,
    required this.top,
    required this.index,
    required this.columnIndex,
    required this.levelIndex,
  });

  double get right => left + size.width;

  double get bottom => top + size.height;

  double get centerX => left + size.width / 2;

  double get centerY => top + size.height / 2;

  double get attributesTop => top + size.headerHeight;

  double get methodsTop => attributesTop + size.attributesHeight;
}

final class ClassBoxPlacement {
  final ClassBoxSizing _sizing;

  const ClassBoxPlacement([this._sizing = const ClassBoxSizing()]);

  List<PlacedClassBox> of(
    List<ClassBox> classes, {
    double boxGap = ClassDiagramMetrics.boxGapFloor,
  }) {
    if (classes.isEmpty) return const [];
    final levels = InheritanceLevels.of(classes);
    final sizes = _sizesOf(levels);
    final grid = ClassColumnGrid.of(
      levels: levels,
      sizes: sizes,
      boxGap: boxGap,
    );
    final placed = <PlacedClassBox>[];
    var top = 0.0;
    var index = 0;
    for (var levelIndex = 0; levelIndex < levels.length; levelIndex++) {
      final level = levels[levelIndex];
      var tallest = 0.0;
      for (final box in level) {
        final size = sizes[box]!;
        final columnIndex = grid.columnOf(box);
        final colLeft = grid.columnLeftAt(columnIndex);
        final colWidth = grid.columnWidthAt(columnIndex);
        final left = colLeft + (colWidth - size.width) / 2;
        placed.add(PlacedClassBox(
          box: box,
          size: size,
          left: left,
          top: top,
          index: index,
          columnIndex: columnIndex,
          levelIndex: levelIndex,
        ));
        tallest = math.max(tallest, size.height);
        index += 1;
      }
      top += tallest + ClassDiagramMetrics.levelGap;
    }
    return List.unmodifiable(placed);
  }

  Map<ClassBox, ClassBoxSize> _sizesOf(List<List<ClassBox>> levels) {
    final sizes = <ClassBox, ClassBoxSize>{};
    for (final level in levels) {
      for (final box in level) {
        sizes[box] = _sizing.of(box);
      }
    }
    return sizes;
  }
}

