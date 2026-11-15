import 'package:flutter/rendering.dart';

final class StackedColumn {
  final List<int> values;

  const StackedColumn(this.values);
}

final class StackedBarsPainter extends CustomPainter {
  final List<StackedColumn> columns;
  final List<Color> colors;
  final Color baselineColor;
  final int peak;
  final double progress;
  final double gapFraction;

  const StackedBarsPainter({
    required this.columns,
    required this.colors,
    required this.baselineColor,
    required this.peak,
    required this.progress,
    this.gapFraction = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (columns.isEmpty) return;
    final slot = size.width / columns.length;
    final barWidth = slot * (1 - gapFraction);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = baselineColor
        ..strokeWidth = 1,
    );
    for (var index = 0; index < columns.length; index++) {
      final left = slot * index + (slot - barWidth) / 2;
      _paintColumn(
        canvas,
        columns[index],
        Rect.fromLTWH(left, 0, barWidth, size.height),
      );
    }
  }

  void _paintColumn(Canvas canvas, StackedColumn column, Rect slot) {
    if (peak == 0) return;
    var bottom = slot.bottom;
    for (var series = 0; series < column.values.length; series++) {
      final height = slot.height * column.values[series] / peak * progress;
      if (height <= 0) continue;
      final rect = Rect.fromLTRB(
        slot.left,
        bottom - height,
        slot.right,
        bottom,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = colors[series % colors.length],
      );
      bottom -= height;
    }
  }

  @override
  bool shouldRepaint(StackedBarsPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.columns != columns ||
      oldDelegate.peak != peak;
}
