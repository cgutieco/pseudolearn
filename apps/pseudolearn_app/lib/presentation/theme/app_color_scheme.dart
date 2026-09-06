import 'package:flutter/material.dart';
import 'tokens/color_primitives.dart';
import 'tokens/color_semantic.dart';

ColorScheme buildAppColorScheme(
    AppSemanticColors semantic, Brightness brightness) {
  return _accentRoles(semantic, brightness).copyWith(
    surface: semantic.surfaces.defaultSurface,
    onSurface: semantic.text.primary,
  );
}

ColorScheme _accentRoles(AppSemanticColors semantic, Brightness brightness) {
  return ColorScheme(
    brightness: brightness,
    primary: semantic.actions.primary.bgDefault,
    onPrimary: semantic.actions.primary.fgDefault,
    primaryContainer: semantic.surfaces.brandSubtle,
    onPrimaryContainer: semantic.text.link,
    secondary: semantic.actions.primary.bgDefault,
    onSecondary: semantic.actions.primary.fgDefault,
    secondaryContainer: semantic.surfaces.brandSubtle,
    onSecondaryContainer: semantic.text.link,
    tertiary: semantic.text.link,
    onTertiary: semantic.text.onBrand,
    tertiaryContainer: semantic.surfaces.subtle,
    onTertiaryContainer: semantic.text.primary,
    error: semantic.severities.error.fg,
    onError: semantic.text.onBrand,
    errorContainer: semantic.severities.error.surface,
    onErrorContainer: semantic.severities.error.fg,
    surface: semantic.surfaces.defaultSurface,
    onSurface: semantic.text.primary,
    surfaceDim: semantic.surfaces.canvas,
    surfaceBright: semantic.surfaces.defaultSurface,
    surfaceContainerLowest: semantic.surfaces.defaultSurface,
    surfaceContainerLow: semantic.surfaces.canvas,
    surfaceContainer: semantic.surfaces.subtle,
    surfaceContainerHigh: semantic.surfaces.raised,
    surfaceContainerHighest: semantic.surfaces.overlay,
    onSurfaceVariant: semantic.text.secondary,
    outline: semantic.borders.defaultBorder,
    outlineVariant: semantic.borders.subtle,
    shadow: semantic.surfaces.inverse,
    scrim:
        semantic.surfaces.inverse.withValues(alpha: semantic.opacities.scrim),
    inverseSurface: semantic.surfaces.inverse,
    onInverseSurface: semantic.text.inverse,
    inversePrimary: semantic.surfaces.brandSubtle,
    surfaceTint: ColorPrimitives.transparent,
  );
}
