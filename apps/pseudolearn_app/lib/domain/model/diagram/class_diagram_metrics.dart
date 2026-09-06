import 'dart:math' as math;

final class ClassDiagramMetrics {
  static const double boxMinWidth = 148.0;
  static const double boxMaxWidth = 280.0;
  static const double boxPadding = 8.0;
  static const double headerHeight = 28.0;
  static const double rowHeight = 18.0;
  static const double emptyCompartmentHeight = 14.0;
  static const double visibilityColumn = 12.0;
  static const double levelGap = 72.0;
  static const double boxGapFloor = 64.0;
  static const double canvasMargin = 32.0;
  static const double relationLane = 16.0;
  static const double arrowSize = 12.0;
  static const double selfLoopReach = 28.0;
  static const double corridorClearance = 12.0;

  static double computeBoxGap(double widestLabelWidth) =>
      math.max(boxGapFloor, widestLabelWidth + corridorClearance * 2.0);
}
