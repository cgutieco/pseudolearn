import 'dart:math' as math;
import 'dart:ui';
import '../theme/tokens/brand_metrics.dart';

List<Offset> brandSymbolTurns() {
  var x = BrandMetricsTokens.symbolStartX;
  var y = BrandMetricsTokens.symbolStartY;
  final points = <Offset>[Offset(x, y)];
  for (var step = 0; step < BrandMetricsTokens.symbolTurnCount; step++) {
    if (step.isEven) {
      x += BrandMetricsTokens.symbolRun;
    } else {
      y -= BrandMetricsTokens.symbolRun;
    }
    points.add(Offset(x, y));
  }
  return points;
}

Rect brandSymbolInkBox() {
  final points = brandSymbolTurns();
  const half = BrandMetricsTokens.symbolStroke / 2;
  const radius = BrandMetricsTokens.symbolTerminalRadius;
  var left = points.first.dx - radius;
  var top = points.first.dy - radius;
  var right = points.first.dx + radius;
  var bottom = points.first.dy + radius;
  for (final point in points) {
    left = math.min(left, point.dx - half);
    top = math.min(top, point.dy - half);
    right = math.max(right, point.dx + half);
    bottom = math.max(bottom, point.dy + half);
  }
  return Rect.fromLTRB(left, top, right, bottom);
}

Path buildBrandSymbolPath() {
  final points = brandSymbolTurns();
  const half = BrandMetricsTokens.symbolStroke / 2;
  final path = Path();
  for (var index = 0; index + 1 < points.length; index++) {
    final from = points[index];
    final to = points[index + 1];
    final run = Rect.fromLTRB(
      math.min(from.dx, to.dx) - half,
      math.min(from.dy, to.dy) - half,
      math.max(from.dx, to.dx) + half,
      math.max(from.dy, to.dy) + half,
    );
    path.addRRect(RRect.fromRectAndRadius(run, const Radius.circular(half)));
  }
  path.addOval(Rect.fromCircle(
    center: points.first,
    radius: BrandMetricsTokens.symbolTerminalRadius,
  ));
  _addPennant(path, points.last);
  return path;
}

void _addPennant(Path path, Offset tip) {
  const pennant = BrandMetricsTokens.symbolPennant;
  final top = tip.dy - BrandMetricsTokens.symbolStroke / 2;
  _addRoundedPolygon(
    path,
    <Offset>[
      Offset(tip.dx, top),
      Offset(tip.dx, top + pennant),
      Offset(tip.dx - pennant, top + pennant / 2),
    ],
    BrandMetricsTokens.symbolPennantRadius,
  );
}

void _addRoundedPolygon(Path path, List<Offset> corners, double radius) {
  for (var index = 0; index < corners.length; index++) {
    final corner = corners[index];
    final previous = corners[(index - 1 + corners.length) % corners.length];
    final next = corners[(index + 1) % corners.length];
    final toPrevious = _unit(previous - corner);
    final toNext = _unit(next - corner);
    final halfAngle = math.acos(_cosine(toPrevious, toNext)) / 2;
    final setback = radius / math.tan(halfAngle);
    final entry = corner + toPrevious * setback;
    final exit = corner + toNext * setback;
    if (index == 0) {
      path.moveTo(entry.dx, entry.dy);
    } else {
      path.lineTo(entry.dx, entry.dy);
    }
    path.arcToPoint(exit, radius: Radius.circular(radius));
  }
  path.close();
}

Offset _unit(Offset vector) => vector / vector.distance;

double _cosine(Offset a, Offset b) => math.max(-1.0, math.min(1.0, a.dx * b.dx + a.dy * b.dy));
