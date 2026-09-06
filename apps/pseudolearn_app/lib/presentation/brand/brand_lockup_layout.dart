import 'dart:math' as math;
import 'dart:ui';
import '../theme/tokens/brand_metrics.dart';

enum BrandLockupOrientation { horizontal, vertical }

final class BrandLockupLayout {
  final Size size;
  final Rect plate;
  final Offset wordmark;

  const BrandLockupLayout._({
    required this.size,
    required this.plate,
    required this.wordmark,
  });

  factory BrandLockupLayout.horizontal(double typeSize) {
    final plateSide = BrandMetricsTokens.wordmarkCapHeight * typeSize * BrandMetricsTokens.lockupHorizontalPlate;
    final gap = plateSide * BrandMetricsTokens.lockupHorizontalGap;
    final capCenter = _capCenter(typeSize);
    final top = math.min(BrandMetricsTokens.wordmarkCapTop * typeSize, capCenter - plateSide / 2);
    final bottom = math.max(_inkBottom(typeSize), capCenter + plateSide / 2);
    return BrandLockupLayout._(
      size: Size(plateSide + gap + BrandMetricsTokens.wordmarkInkWidth * typeSize, bottom - top),
      plate: Rect.fromLTWH(0, capCenter - plateSide / 2 - top, plateSide, plateSide),
      wordmark: Offset(plateSide + gap, BrandMetricsTokens.wordmarkInkTop * typeSize - top),
    );
  }

  factory BrandLockupLayout.vertical(double typeSize) {
    final plateSide = BrandMetricsTokens.wordmarkCapHeight * typeSize * BrandMetricsTokens.lockupVerticalPlate;
    final gap = plateSide * BrandMetricsTokens.lockupVerticalGap;
    final width = BrandMetricsTokens.wordmarkInkWidth * typeSize;
    final capTop = BrandMetricsTokens.wordmarkCapTop * typeSize;
    return BrandLockupLayout._(
      size: Size(width, plateSide + gap + _inkBottom(typeSize) - capTop),
      plate: Rect.fromLTWH((width - plateSide) / 2, 0, plateSide, plateSide),
      wordmark: Offset(0, plateSide + gap - capTop + BrandMetricsTokens.wordmarkInkTop * typeSize),
    );
  }

  factory BrandLockupLayout.of({
    required BrandLockupOrientation orientation,
    required double typeSize,
  }) {
    return switch (orientation) {
      BrandLockupOrientation.horizontal => BrandLockupLayout.horizontal(typeSize),
      BrandLockupOrientation.vertical => BrandLockupLayout.vertical(typeSize),
    };
  }
  double get clearSpace => plate.width * BrandMetricsTokens.lockupClearSpace;
}

double _capCenter(double typeSize) =>
    (BrandMetricsTokens.wordmarkCapTop + BrandMetricsTokens.wordmarkCapBaseline) / 2 * typeSize;

double _inkBottom(double typeSize) =>
    (BrandMetricsTokens.wordmarkInkTop + BrandMetricsTokens.wordmarkInkHeight) * typeSize;
