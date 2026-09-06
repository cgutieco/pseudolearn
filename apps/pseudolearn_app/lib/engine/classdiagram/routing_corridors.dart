import 'dart:math' as math;

import '../../domain/model/diagram/class_diagram_metrics.dart';
import 'class_box_placement.dart';

final class _Bounds {
  int maxCol = 0;
  int maxLevel = 0;
  double minL = double.infinity;
  double maxR = double.negativeInfinity;
  double minT = double.infinity;
  double maxB = double.negativeInfinity;
}

final class RoutingCorridors {
  final List<PlacedClassBox> _boxes;
  final List<double> _columnRights;
  final List<double> _columnLefts;
  final List<double> _levelBottoms;
  final List<double> _levelTops;
  final double _minLeft;
  final double _maxRight;
  final double _minTop;
  final double _maxBottom;
  final double _boxGap;

  RoutingCorridors._({
    required List<PlacedClassBox> boxes,
    required List<double> columnRights,
    required List<double> columnLefts,
    required List<double> levelBottoms,
    required List<double> levelTops,
    required double minLeft,
    required double maxRight,
    required double minTop,
    required double maxBottom,
    required double boxGap,
  })  : _boxes = boxes,
        _columnRights = columnRights,
        _columnLefts = columnLefts,
        _levelBottoms = levelBottoms,
        _levelTops = levelTops,
        _minLeft = minLeft,
        _maxRight = maxRight,
        _minTop = minTop,
        _maxBottom = maxBottom,
        _boxGap = boxGap;

  factory RoutingCorridors.of(List<PlacedClassBox> boxes,
      {double boxGap = ClassDiagramMetrics.boxGapFloor}) {
    if (boxes.isEmpty) {
      return RoutingCorridors._(
        boxes: const [],
        columnRights: const [],
        columnLefts: const [],
        levelBottoms: const [],
        levelTops: const [],
        minLeft: 0.0,
        maxRight: 0.0,
        minTop: 0.0,
        maxBottom: 0.0,
        boxGap: boxGap,
      );
    }
    return _create(boxes, boxGap);
  }

  static RoutingCorridors _create(List<PlacedClassBox> boxes, double boxGap) {
    final b = _scanBounds(boxes);
    final colRights =
        List<double>.filled(b.maxCol + 1, double.negativeInfinity);
    final colLefts = List<double>.filled(b.maxCol + 1, double.infinity);
    final levelBottoms =
        List<double>.filled(b.maxLevel + 1, double.negativeInfinity);
    final levelTops = List<double>.filled(b.maxLevel + 1, double.infinity);
    _populateExtents(
      boxes: boxes,
      colRights: colRights,
      colLefts: colLefts,
      levelBottoms: levelBottoms,
      levelTops: levelTops,
    );

    return RoutingCorridors._(
      boxes: boxes,
      columnRights: colRights,
      columnLefts: colLefts,
      levelBottoms: levelBottoms,
      levelTops: levelTops,
      minLeft: b.minL,
      maxRight: b.maxR,
      minTop: b.minT,
      maxBottom: b.maxB,
      boxGap: boxGap,
    );
  }

  static _Bounds _scanBounds(List<PlacedClassBox> boxes) {
    final b = _Bounds();
    for (final box in boxes) {
      b.maxCol = math.max(b.maxCol, box.columnIndex);
      b.maxLevel = math.max(b.maxLevel, box.levelIndex);
      b.minL = math.min(b.minL, box.left);
      b.maxR = math.max(b.maxR, box.right);
      b.minT = math.min(b.minT, box.top);
      b.maxB = math.max(b.maxB, box.bottom);
    }
    return b;
  }

  static void _populateExtents({
    required List<PlacedClassBox> boxes,
    required List<double> colRights,
    required List<double> colLefts,
    required List<double> levelBottoms,
    required List<double> levelTops,
  }) {
    for (final box in boxes) {
      colRights[box.columnIndex] =
          math.max(colRights[box.columnIndex], box.right);
      colLefts[box.columnIndex] = math.min(colLefts[box.columnIndex], box.left);
      levelBottoms[box.levelIndex] =
          math.max(levelBottoms[box.levelIndex], box.bottom);
      levelTops[box.levelIndex] = math.min(levelTops[box.levelIndex], box.top);
    }
  }

  double verticalCorridorX({required int columnAfter, int sublane = 0}) {
    final offset = sublane * ClassDiagramMetrics.relationLane;
    if (columnAfter < 0) return _minLeft - _boxGap / 2 - offset;
    if (columnAfter >= _columnRights.length - 1) {
      return _maxRight + _boxGap / 2 + offset;
    }
    final center =
        (_columnRights[columnAfter] + _columnLefts[columnAfter + 1]) / 2;
    return center + offset;
  }

  double horizontalBandY({required int levelAfter, int sublane = 0}) {
    final offset = sublane * ClassDiagramMetrics.relationLane;
    if (levelAfter < 0) {
      return _minTop - ClassDiagramMetrics.levelGap / 2 - offset;
    }
    if (levelAfter >= _levelBottoms.length - 1) {
      return _maxBottom + ClassDiagramMetrics.levelGap / 2 + offset;
    }
    final center = (_levelBottoms[levelAfter] + _levelTops[levelAfter + 1]) / 2;
    return center + offset;
  }

  bool isVerticalClear(double x, double y1, double y2,
      {PlacedClassBox? fromBox, PlacedClassBox? toBox}) {
    final top = math.min(y1, y2);
    final bottom = math.max(y1, y2);
    const clearance = ClassDiagramMetrics.corridorClearance;
    for (final box in _boxes) {
      final isEndpoint = identical(box, fromBox) || identical(box, toBox);
      final boxL = isEndpoint ? box.left + 0.5 : box.left - clearance;
      final boxR = isEndpoint ? box.right - 0.5 : box.right + clearance;
      final boxT = isEndpoint ? box.top + 0.5 : box.top - clearance;
      final boxB = isEndpoint ? box.bottom - 0.5 : box.bottom + clearance;

      if (x > boxL && x < boxR && bottom > boxT && top < boxB) {
        return false;
      }
    }
    return true;
  }

  bool isHorizontalClear(double y, double x1, double x2,
      {PlacedClassBox? fromBox, PlacedClassBox? toBox}) {
    final left = math.min(x1, x2);
    final right = math.max(x1, x2);
    const clearance = ClassDiagramMetrics.corridorClearance;
    for (final box in _boxes) {
      final isEndpoint = identical(box, fromBox) || identical(box, toBox);
      final boxL = isEndpoint ? box.left + 0.5 : box.left - clearance;
      final boxR = isEndpoint ? box.right - 0.5 : box.right + clearance;
      final boxT = isEndpoint ? box.top + 0.5 : box.top - clearance;
      final boxB = isEndpoint ? box.bottom - 0.5 : box.bottom + clearance;

      if (y > boxT && y < boxB && right > boxL && left < boxR) {
        return false;
      }
    }
    return true;
  }

  int get columnCount => _columnRights.length;

  int get levelCount => _levelBottoms.length;
}
