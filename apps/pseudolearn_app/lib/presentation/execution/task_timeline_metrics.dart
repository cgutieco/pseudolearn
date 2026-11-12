import '../theme/tokens/spacing.dart';

final class TaskTimelineMetrics {
  static const double rowHeight = SpacingTokens.space10;
  static const double indexWidth = SpacingTokens.space10;
  static const double maximumColumnWidth = SpacingTokens.space8;
  static const double minimumColumnWidth = SpacingTokens.space4;
  static const double laneShare = 0.45;
  static const double compactPaneHeight =
      SpacingTokens.space20 * 4 + SpacingTokens.space10;

  const TaskTimelineMetrics._();

  static double columnWidth({required double width, required int columns}) {
    final available = (width - indexWidth) * laneShare;
    final share = columns <= 0 ? maximumColumnWidth : available / columns;
    return share.clamp(minimumColumnWidth, maximumColumnWidth).toDouble();
  }

  static double centeredOffset({
    required int rowIndex,
    required double viewport,
    required double maximum,
  }) {
    final target = rowIndex * rowHeight - (viewport - rowHeight) / 2;
    return target.clamp(0, maximum < 0 ? 0 : maximum).toDouble();
  }
}
