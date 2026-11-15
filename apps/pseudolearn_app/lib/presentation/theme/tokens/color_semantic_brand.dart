import 'dart:ui';
import 'color_primitives.dart';

final class BrandPlateColors {
  final Color groundTop, groundBottom, ink;

  const BrandPlateColors.light()
      : groundTop = ColorPrimitives.brand800,
        groundBottom = ColorPrimitives.brand900,
        ink = ColorPrimitives.neutral0;

  const BrandPlateColors.dark()
      : groundTop = ColorPrimitives.brand900,
        groundBottom = ColorPrimitives.brand950,
        ink = ColorPrimitives.brand100;

  const BrandPlateColors.of({
    required this.groundTop,
    required this.groundBottom,
    required this.ink,
  });

  static BrandPlateColors lerp(BrandPlateColors a, BrandPlateColors b, double t) => BrandPlateColors.of(
    groundTop: Color.lerp(a.groundTop, b.groundTop, t)!,
    groundBottom: Color.lerp(a.groundBottom, b.groundBottom, t)!,
    ink: Color.lerp(a.ink, b.ink, t)!,
  );
}

final class BrandInkColors {
  final Color signature, wordmark;

  const BrandInkColors.light()
      : signature = ColorPrimitives.brand700,
        wordmark = ColorPrimitives.brand900;

  const BrandInkColors.dark()
      : signature = ColorPrimitives.brand300,
        wordmark = ColorPrimitives.neutral0;

  const BrandInkColors.of({required this.signature, required this.wordmark});

  static BrandInkColors lerp(BrandInkColors a, BrandInkColors b, double t) => BrandInkColors.of(
    signature: Color.lerp(a.signature, b.signature, t)!,
    wordmark: Color.lerp(a.wordmark, b.wordmark, t)!,
  );
}
