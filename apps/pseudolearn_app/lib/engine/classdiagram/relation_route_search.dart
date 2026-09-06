import 'dart:math' as math;

import '../../domain/model/diagram/diagram_scene.dart';
import 'class_box_placement.dart';
import 'routing_corridors.dart';
import 'routing_reservations.dart';

final class RelationRouteSearch {
  final RoutingCorridors _corridors;
  final RoutingReservations _reservations;

  const RelationRouteSearch({
    required RoutingCorridors corridors,
    required RoutingReservations reservations,
  })  : _corridors = corridors,
        _reservations = reservations;

  List<DiagramPoint> findAssociationRoute({
    required PlacedClassBox fromBox,
    required DiagramPoint fromAnchor,
    required PlacedClassBox toBox,
    required DiagramPoint toAnchor,
  }) {
    final direct = _tryDirectRoute(
      from: fromBox,
      fromPt: fromAnchor,
      to: toBox,
      toPt: toAnchor,
    );
    if (direct != null) return direct;

    final bandRoute = _tryCorridorBandRoute(
      from: fromBox,
      fromPt: fromAnchor,
      to: toBox,
      toPt: toAnchor,
    );
    if (bandRoute != null) return bandRoute;

    return _fallbackOuterRoute(
      from: fromBox,
      fromPt: fromAnchor,
      to: toBox,
      toPt: toAnchor,
    );
  }

  List<DiagramPoint>? _tryDirectRoute({
    required PlacedClassBox from,
    required DiagramPoint fromPt,
    required PlacedClassBox to,
    required DiagramPoint toPt,
  }) {
    final candidateCols = _candidateDirectCorridors(from: from, fromPt: fromPt, to: to);

    for (final col in candidateCols) {
      final sublane = _reservations.findVerticalSublane(corridorIndex: col, y1: fromPt.y, y2: toPt.y);
      final x = _corridors.verticalCorridorX(columnAfter: col, sublane: sublane);

      final clear1 = _corridors.isHorizontalClear(fromPt.y, fromPt.x, x, fromBox: from, toBox: to);
      final clearV = _corridors.isVerticalClear(x, fromPt.y, toPt.y, fromBox: from, toBox: to);
      final clear2 = _corridors.isHorizontalClear(toPt.y, x, toPt.x, fromBox: from, toBox: to);

      if (clear1 && clearV && clear2) {
        _reservations.commitVertical(corridorIndex: col, sublane: sublane, y1: fromPt.y, y2: toPt.y);
        return [
          fromPt,
          DiagramPoint(x, fromPt.y),
          DiagramPoint(x, toPt.y),
          toPt,
        ];
      }
    }
    return null;
  }

  List<int> _candidateDirectCorridors({
    required PlacedClassBox from,
    required DiagramPoint fromPt,
    required PlacedClassBox to,
  }) {
    final list = <int>[];
    if (from.columnIndex == to.columnIndex) {
      final isRight = fromPt.x >= from.centerX;
      list.add(isRight ? from.columnIndex : from.columnIndex - 1);
    } else {
      final minC = math.min(from.columnIndex, to.columnIndex);
      final maxC = math.max(from.columnIndex, to.columnIndex);
      for (var c = minC; c < maxC; c++) {
        list.add(c);
      }
    }
    return list;
  }

  List<DiagramPoint>? _tryCorridorBandRoute({
    required PlacedClassBox from,
    required DiagramPoint fromPt,
    required PlacedClassBox to,
    required DiagramPoint toPt,
  }) {
    final col1 = fromPt.x > from.centerX ? from.columnIndex : from.columnIndex - 1;
    final col2 = toPt.x > to.centerX ? to.columnIndex : to.columnIndex - 1;

    for (var bandLvl = -1; bandLvl <= _corridors.levelCount; bandLvl++) {
      final points = _trySingleBandCandidate(
        from: from,
        fromPt: fromPt,
        to: to,
        toPt: toPt,
        col1: col1,
        col2: col2,
        bandLvl: bandLvl,
      );
      if (points != null) return points;
    }
    return null;
  }

  List<DiagramPoint>? _trySingleBandCandidate({
    required PlacedClassBox from,
    required DiagramPoint fromPt,
    required PlacedClassBox to,
    required DiagramPoint toPt,
    required int col1,
    required int col2,
    required int bandLvl,
  }) {
    final approxY = _corridors.horizontalBandY(levelAfter: bandLvl, sublane: 0);
    final sublane1 = _reservations.findVerticalSublane(corridorIndex: col1, y1: fromPt.y, y2: approxY);
    final x1 = _corridors.verticalCorridorX(columnAfter: col1, sublane: sublane1);

    final sublane2 = _reservations.findVerticalSublane(corridorIndex: col2, y1: approxY, y2: toPt.y);
    final x2 = _corridors.verticalCorridorX(columnAfter: col2, sublane: sublane2);

    final bandSub = _reservations.findHorizontalSublane(bandIndex: bandLvl, x1: x1, x2: x2);
    final yBand = _corridors.horizontalBandY(levelAfter: bandLvl, sublane: bandSub);

    final clear1 = _corridors.isHorizontalClear(fromPt.y, fromPt.x, x1, fromBox: from, toBox: to);
    final clear2 = _corridors.isVerticalClear(x1, fromPt.y, yBand, fromBox: from, toBox: to);
    final clear3 = _corridors.isHorizontalClear(yBand, x1, x2, fromBox: from, toBox: to);
    final clear4 = _corridors.isVerticalClear(x2, yBand, toPt.y, fromBox: from, toBox: to);
    final clear5 = _corridors.isHorizontalClear(toPt.y, x2, toPt.x, fromBox: from, toBox: to);

    if (clear1 && clear2 && clear3 && clear4 && clear5) {
      _reservations.commitVertical(corridorIndex: col1, sublane: sublane1, y1: fromPt.y, y2: yBand);
      _reservations.commitHorizontal(bandIndex: bandLvl, sublane: bandSub, x1: x1, x2: x2);
      _reservations.commitVertical(corridorIndex: col2, sublane: sublane2, y1: yBand, y2: toPt.y);
      return [
        fromPt,
        DiagramPoint(x1, fromPt.y),
        DiagramPoint(x1, yBand),
        DiagramPoint(x2, yBand),
        DiagramPoint(x2, toPt.y),
        toPt,
      ];
    }
    return null;
  }

  List<DiagramPoint> _fallbackOuterRoute({
    required PlacedClassBox from,
    required DiagramPoint fromPt,
    required PlacedClassBox to,
    required DiagramPoint toPt,
  }) {
    final col1 = fromPt.x > from.centerX ? from.columnIndex : from.columnIndex - 1;
    final col2 = toPt.x > to.centerX ? to.columnIndex : to.columnIndex - 1;
    final bandLvl = _corridors.levelCount;
    final approxY = _corridors.horizontalBandY(levelAfter: bandLvl, sublane: 0);

    final sublane1 = _reservations.findVerticalSublane(corridorIndex: col1, y1: fromPt.y, y2: approxY);
    final x1 = _corridors.verticalCorridorX(columnAfter: col1, sublane: sublane1);

    final sublane2 = _reservations.findVerticalSublane(corridorIndex: col2, y1: approxY, y2: toPt.y);
    final x2 = _corridors.verticalCorridorX(columnAfter: col2, sublane: sublane2);

    final bandSub = _reservations.findHorizontalSublane(bandIndex: bandLvl, x1: x1, x2: x2);
    final yBand = _corridors.horizontalBandY(levelAfter: bandLvl, sublane: bandSub);

    _reservations.commitVertical(corridorIndex: col1, sublane: sublane1, y1: fromPt.y, y2: yBand);
    _reservations.commitHorizontal(bandIndex: bandLvl, sublane: bandSub, x1: x1, x2: x2);
    _reservations.commitVertical(corridorIndex: col2, sublane: sublane2, y1: yBand, y2: toPt.y);

    return [
      fromPt,
      DiagramPoint(x1, fromPt.y),
      DiagramPoint(x1, yBand),
      DiagramPoint(x2, yBand),
      DiagramPoint(x2, toPt.y),
      toPt,
    ];
  }
}
