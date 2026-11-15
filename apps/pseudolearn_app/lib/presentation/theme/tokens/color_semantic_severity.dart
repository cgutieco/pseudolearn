import 'dart:ui';
import 'color_primitives.dart';

final class SeverityItemColors {
  final Color fg, surface, border;

  const SeverityItemColors({
    required this.fg,
    required this.surface,
    required this.border,
  });

  const SeverityItemColors.of({
    required this.fg,
    required this.surface,
    required this.border,
  });

  static SeverityItemColors lerp(SeverityItemColors a, SeverityItemColors b, double t) => SeverityItemColors.of(
    fg: Color.lerp(a.fg, b.fg, t)!,
    surface: Color.lerp(a.surface, b.surface, t)!,
    border: Color.lerp(a.border, b.border, t)!,
  );

}

final class SeverityColors {
  final SeverityItemColors error, warning, info, hint, success;

  const SeverityColors.light()
      : error = const SeverityItemColors(fg: ColorPrimitives.red700, surface: ColorPrimitives.red100, border: ColorPrimitives.red600),
        warning = const SeverityItemColors(fg: ColorPrimitives.amber800, surface: ColorPrimitives.amber100, border: ColorPrimitives.amber600),
        info = const SeverityItemColors(fg: ColorPrimitives.blue700, surface: ColorPrimitives.blue100, border: ColorPrimitives.blue600),
        hint = const SeverityItemColors(fg: ColorPrimitives.neutral700, surface: ColorPrimitives.neutral100, border: ColorPrimitives.neutral600),
        success = const SeverityItemColors(fg: ColorPrimitives.green700, surface: ColorPrimitives.green100, border: ColorPrimitives.green600);

  const SeverityColors.dark()
      : error = const SeverityItemColors(fg: ColorPrimitives.red300, surface: ColorPrimitives.tintRedDark, border: ColorPrimitives.red500),
        warning = const SeverityItemColors(fg: ColorPrimitives.amber300, surface: ColorPrimitives.tintAmberDark, border: ColorPrimitives.amber500),
        info = const SeverityItemColors(fg: ColorPrimitives.blue300, surface: ColorPrimitives.tintBlueDark, border: ColorPrimitives.blue500),
        hint = const SeverityItemColors(fg: ColorPrimitives.neutral400, surface: ColorPrimitives.neutral850, border: ColorPrimitives.neutral500),
        success = const SeverityItemColors(fg: ColorPrimitives.green300, surface: ColorPrimitives.tintGreenDark, border: ColorPrimitives.green500);

  const SeverityColors.of({
    required this.error,
    required this.warning,
    required this.info,
    required this.hint,
    required this.success,
  });

  static SeverityColors lerp(SeverityColors a, SeverityColors b, double t) => SeverityColors.of(
    error: SeverityItemColors.lerp(a.error, b.error, t),
    warning: SeverityItemColors.lerp(a.warning, b.warning, t),
    info: SeverityItemColors.lerp(a.info, b.info, t),
    hint: SeverityItemColors.lerp(a.hint, b.hint, t),
    success: SeverityItemColors.lerp(a.success, b.success, t),
  );

}

final class OpacityMetrics {
  final double scrim, dragGhost, canvasWatermark;

  const OpacityMetrics.light() : scrim = 0.48, dragGhost = 0.80, canvasWatermark = 0.06;
  const OpacityMetrics.dark() : scrim = 0.64, dragGhost = 0.80, canvasWatermark = 0.06;

  const OpacityMetrics.of({
    required this.scrim,
    required this.dragGhost,
    required this.canvasWatermark,
  });

  static OpacityMetrics lerp(OpacityMetrics a, OpacityMetrics b, double t) => OpacityMetrics.of(
    scrim: a.scrim + (b.scrim - a.scrim) * t,
    dragGhost: a.dragGhost + (b.dragGhost - a.dragGhost) * t,
    canvasWatermark: a.canvasWatermark + (b.canvasWatermark - a.canvasWatermark) * t,
  );

}
