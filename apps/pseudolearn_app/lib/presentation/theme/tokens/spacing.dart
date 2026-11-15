final class SpacingTokens {
  static const double spaceHalf = 2.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;
  static const double space20 = 80.0;

  static const double targetTouchMin = 48.0;
  static const double targetPointerMin = 32.0;
  static const double targetSpacingMin = 8.0;
  static const double targetInlineMin = 24.0;
}

enum ContentMeasure { reading, form, wide, full }

final class LayoutMetrics {
  final double screenMargin;
  final double densityScale;
  final double navWidth;
  final double readingMax;
  final double formMax;
  final double wideMax;
  final int cardColumns;

  const LayoutMetrics.compact()
      : screenMargin = 16.0,
        densityScale = 1.0,
        navWidth = 0.0,
        readingMax = 680.0,
        formMax = 480.0,
        wideMax = 1080.0,
        cardColumns = 1;

  const LayoutMetrics.medium()
      : screenMargin = 24.0,
        densityScale = 1.0,
        navWidth = 80.0,
        readingMax = 680.0,
        formMax = 520.0,
        wideMax = 1080.0,
        cardColumns = 2;

  const LayoutMetrics.expanded()
      : screenMargin = 32.0,
        densityScale = 1.05,
        navWidth = 88.0,
        readingMax = 720.0,
        formMax = 560.0,
        wideMax = 1440.0,
        cardColumns = 3;

  double maxWidthFor(ContentMeasure measure) => switch (measure) {
        ContentMeasure.reading => readingMax,
        ContentMeasure.form => formMax,
        ContentMeasure.wide => wideMax,
        ContentMeasure.full => double.infinity,
      };
}
