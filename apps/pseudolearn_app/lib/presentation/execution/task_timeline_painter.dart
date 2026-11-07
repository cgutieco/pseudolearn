import 'package:flutter/material.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../theme/tokens/border_metrics.dart';
import '../theme/tokens/spacing.dart';

final class TaskTimelinePalette {
  final Color lane;
  final Color dot;
  final Color link;
  final Color hollow;

  const TaskTimelinePalette({
    required this.lane,
    required this.dot,
    required this.link,
    required this.hollow,
  });
}

final class TaskTimelinePainter extends CustomPainter {
  final TaskFlowRow row;
  final int columnCount;
  final double columnWidth;
  final TaskTimelinePalette palette;

  const TaskTimelinePainter({
    required this.row,
    required this.columnCount,
    required this.columnWidth,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.height / 2;
    final lane = Paint()
      ..color = palette.lane
      ..strokeWidth = BorderMetricsTokens.widthHairline;
    for (var column = 0; column < columnCount; column++) {
      final x = _x(column);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lane);
    }
    for (final target in row.linkedColumns) {
      _paintLink(canvas, target, middle);
    }
    final radius = row.kind.isQuiet
        ? SpacingTokens.space1 - SpacingTokens.spaceHalf / 2
        : SpacingTokens.space1 + SpacingTokens.spaceHalf;
    canvas.drawCircle(
      Offset(_x(row.column), middle),
      radius,
      Paint()..color = palette.dot,
    );
  }

  void _paintLink(Canvas canvas, int target, double middle) {
    final paint = Paint()
      ..color = palette.link
      ..strokeWidth = BorderMetricsTokens.widthEmphasis;
    final start = _x(row.column);
    final end = _x(target);
    if (row.linkKind == TaskFlowLinkKind.creation) {
      canvas.drawLine(Offset(start, middle), Offset(end, middle), paint);
    } else {
      _paintDashes(canvas, from: start, to: end, middle: middle, paint: paint);
    }
    canvas.drawCircle(
      Offset(end, middle),
      SpacingTokens.space1,
      Paint()..color = palette.hollow,
    );
    canvas.drawCircle(
      Offset(end, middle),
      SpacingTokens.space1,
      paint..style = PaintingStyle.stroke,
    );
  }

  void _paintDashes(
    Canvas canvas, {
    required double from,
    required double to,
    required double middle,
    required Paint paint,
  }) {
    final direction = to >= from ? 1.0 : -1.0;
    final length = (to - from).abs();
    for (var step = 0.0; step < length; step += SpacingTokens.space2) {
      final dashStart = from + direction * step;
      final dashEnd = from + direction * (step + SpacingTokens.space1);
      canvas.drawLine(
        Offset(dashStart, middle),
        Offset(dashEnd, middle),
        paint,
      );
    }
  }

  double _x(int column) => (column + 0.5) * columnWidth;

  @override
  bool shouldRepaint(covariant TaskTimelinePainter oldDelegate) =>
      oldDelegate.row != row ||
      oldDelegate.columnCount != columnCount ||
      oldDelegate.columnWidth != columnWidth ||
      oldDelegate.palette.dot != palette.dot ||
      oldDelegate.palette.lane != palette.lane;
}
