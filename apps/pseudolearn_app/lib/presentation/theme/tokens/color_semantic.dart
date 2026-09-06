import 'dart:ui';
import 'color_primitives.dart';
import 'color_semantic_actions.dart';
import 'color_semantic_brand.dart';
import 'color_semantic_severity.dart';

export 'color_semantic_actions.dart';
export 'color_semantic_brand.dart';
export 'color_semantic_severity.dart';

final class SurfaceColors {
  final Color canvas, defaultSurface, subtle, raised, overlay, editor, inverse, brandSubtle;

  const SurfaceColors.light()
      : canvas = ColorPrimitives.neutral50,
        defaultSurface = ColorPrimitives.neutral0,
        subtle = ColorPrimitives.neutral100,
        raised = ColorPrimitives.neutral0,
        overlay = ColorPrimitives.neutral0,
        editor = ColorPrimitives.neutral0,
        inverse = ColorPrimitives.neutral900,
        brandSubtle = ColorPrimitives.brand100;

  const SurfaceColors.dark()
      : canvas = ColorPrimitives.neutral950,
        defaultSurface = ColorPrimitives.neutral900,
        subtle = ColorPrimitives.neutral1000,
        raised = ColorPrimitives.neutral850,
        overlay = ColorPrimitives.neutral850,
        editor = ColorPrimitives.neutral1000,
        inverse = ColorPrimitives.neutral100,
        brandSubtle = ColorPrimitives.brand950;

  const SurfaceColors.of({
    required this.canvas,
    required this.defaultSurface,
    required this.subtle,
    required this.raised,
    required this.overlay,
    required this.editor,
    required this.inverse,
    required this.brandSubtle,
  });

  static SurfaceColors lerp(SurfaceColors a, SurfaceColors b, double t) => SurfaceColors.of(
    canvas: Color.lerp(a.canvas, b.canvas, t)!,
    defaultSurface: Color.lerp(a.defaultSurface, b.defaultSurface, t)!,
    subtle: Color.lerp(a.subtle, b.subtle, t)!,
    raised: Color.lerp(a.raised, b.raised, t)!,
    overlay: Color.lerp(a.overlay, b.overlay, t)!,
    editor: Color.lerp(a.editor, b.editor, t)!,
    inverse: Color.lerp(a.inverse, b.inverse, t)!,
    brandSubtle: Color.lerp(a.brandSubtle, b.brandSubtle, t)!,
  );

}

final class TextColors {
  final Color primary, secondary, tertiary, disabled, onBrand, inverse, link;

  const TextColors.light()
      : primary = ColorPrimitives.neutral900,
        secondary = ColorPrimitives.neutral700,
        tertiary = ColorPrimitives.neutral600,
        disabled = ColorPrimitives.neutral500,
        onBrand = ColorPrimitives.neutral0,
        inverse = ColorPrimitives.neutral25,
        link = ColorPrimitives.brand700;

  const TextColors.dark()
      : primary = ColorPrimitives.neutral100,
        secondary = ColorPrimitives.neutral400,
        tertiary = ColorPrimitives.neutral500,
        disabled = ColorPrimitives.neutral600,
        onBrand = ColorPrimitives.neutral1000,
        inverse = ColorPrimitives.neutral900,
        link = ColorPrimitives.brand300;

  const TextColors.of({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.disabled,
    required this.onBrand,
    required this.inverse,
    required this.link,
  });

  static TextColors lerp(TextColors a, TextColors b, double t) => TextColors.of(
    primary: Color.lerp(a.primary, b.primary, t)!,
    secondary: Color.lerp(a.secondary, b.secondary, t)!,
    tertiary: Color.lerp(a.tertiary, b.tertiary, t)!,
    disabled: Color.lerp(a.disabled, b.disabled, t)!,
    onBrand: Color.lerp(a.onBrand, b.onBrand, t)!,
    inverse: Color.lerp(a.inverse, b.inverse, t)!,
    link: Color.lerp(a.link, b.link, t)!,
  );

}

final class BorderColors {
  final Color subtle, defaultBorder, strong, focus, inverse;

  const BorderColors.light()
      : subtle = ColorPrimitives.neutral100,
        defaultBorder = ColorPrimitives.neutral200,
        strong = ColorPrimitives.neutral500,
        focus = ColorPrimitives.brand600,
        inverse = ColorPrimitives.neutral700;

  const BorderColors.dark()
      : subtle = ColorPrimitives.neutral850,
        defaultBorder = ColorPrimitives.neutral800,
        strong = ColorPrimitives.neutral500,
        focus = ColorPrimitives.brand400,
        inverse = ColorPrimitives.neutral300;

  const BorderColors.of({
    required this.subtle,
    required this.defaultBorder,
    required this.strong,
    required this.focus,
    required this.inverse,
  });

  static BorderColors lerp(BorderColors a, BorderColors b, double t) => BorderColors.of(
    subtle: Color.lerp(a.subtle, b.subtle, t)!,
    defaultBorder: Color.lerp(a.defaultBorder, b.defaultBorder, t)!,
    strong: Color.lerp(a.strong, b.strong, t)!,
    focus: Color.lerp(a.focus, b.focus, t)!,
    inverse: Color.lerp(a.inverse, b.inverse, t)!,
  );

}

final class AppSemanticColors {
  final SurfaceColors surfaces;
  final TextColors text;
  final BorderColors borders;
  final ActionColors actions;
  final SeverityColors severities;
  final BrandPlateColors brandPlate;
  final BrandInkColors brandInk;
  final OpacityMetrics opacities;

  const AppSemanticColors.light()
      : surfaces = const SurfaceColors.light(),
        text = const TextColors.light(),
        borders = const BorderColors.light(),
        actions = const ActionColors.light(),
        severities = const SeverityColors.light(),
        brandPlate = const BrandPlateColors.light(),
        brandInk = const BrandInkColors.light(),
        opacities = const OpacityMetrics.light();

  const AppSemanticColors.dark()
      : surfaces = const SurfaceColors.dark(),
        text = const TextColors.dark(),
        borders = const BorderColors.dark(),
        actions = const ActionColors.dark(),
        severities = const SeverityColors.dark(),
        brandPlate = const BrandPlateColors.dark(),
        brandInk = const BrandInkColors.dark(),
        opacities = const OpacityMetrics.dark();

  const AppSemanticColors.of({
    required this.surfaces,
    required this.text,
    required this.borders,
    required this.actions,
    required this.severities,
    required this.brandPlate,
    required this.brandInk,
    required this.opacities,
  });

  static AppSemanticColors lerp(AppSemanticColors a, AppSemanticColors b, double t) => AppSemanticColors.of(
    surfaces: SurfaceColors.lerp(a.surfaces, b.surfaces, t),
    text: TextColors.lerp(a.text, b.text, t),
    borders: BorderColors.lerp(a.borders, b.borders, t),
    actions: ActionColors.lerp(a.actions, b.actions, t),
    severities: SeverityColors.lerp(a.severities, b.severities, t),
    brandPlate: BrandPlateColors.lerp(a.brandPlate, b.brandPlate, t),
    brandInk: BrandInkColors.lerp(a.brandInk, b.brandInk, t),
    opacities: OpacityMetrics.lerp(a.opacities, b.opacities, t),
  );

}
