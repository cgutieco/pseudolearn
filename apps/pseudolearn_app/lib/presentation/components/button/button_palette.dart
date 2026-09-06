import 'package:flutter/material.dart';
import '../../theme/tokens/color_primitives.dart';
import '../../theme/tokens/color_semantic.dart';

enum AppButtonVariant { primary, secondary, tertiary, brandApple }

final class ButtonPalette {
  final Color bgDefault, bgHover, bgPressed, bgDisabled;
  final Color fgDefault, fgDisabled;
  final Color? borderDefault, borderDisabled;

  const ButtonPalette({
    required this.bgDefault,
    required this.bgHover,
    required this.bgPressed,
    required this.bgDisabled,
    required this.fgDefault,
    required this.fgDisabled,
    this.borderDefault,
    this.borderDisabled,
  });

  factory ButtonPalette.forVariant(
    ActionColors actions,
    AppButtonVariant variant, {
    required bool destructive,
    required bool isDark,
  }) {
    if (destructive) return _destructivePalette(actions.destructive);
    return switch (variant) {
      AppButtonVariant.primary => _primaryPalette(actions.primary),
      AppButtonVariant.secondary => _secondaryPalette(actions.secondary),
      AppButtonVariant.tertiary => _tertiaryPalette(actions.tertiary),
      AppButtonVariant.brandApple =>
        isDark ? _appleCanvasPalette() : _appleInkPalette(),
    };
  }

  Color background(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return bgDisabled;
    if (states.contains(WidgetState.pressed)) return bgPressed;
    if (states.contains(WidgetState.hovered)) return bgHover;
    return bgDefault;
  }

  Color foreground(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled) ? fgDisabled : fgDefault;

  Color? border(Set<WidgetState> states) {
    if (borderDefault == null) return null;
    return states.contains(WidgetState.disabled) ? borderDisabled : borderDefault;
  }
}

ButtonPalette _primaryPalette(ActionPrimaryColors c) => ButtonPalette(
      bgDefault: c.bgDefault,
      bgHover: c.bgHover,
      bgPressed: c.bgPressed,
      bgDisabled: c.bgDisabled,
      fgDefault: c.fgDefault,
      fgDisabled: c.fgDisabled,
    );

ButtonPalette _secondaryPalette(ActionSecondaryColors c) => ButtonPalette(
      bgDefault: c.bgDefault,
      bgHover: c.bgHover,
      bgPressed: c.bgPressed,
      bgDisabled: c.bgDisabled,
      fgDefault: c.fgDefault,
      fgDisabled: c.fgDisabled,
      borderDefault: c.borderDefault,
      borderDisabled: c.borderDisabled,
    );

ButtonPalette _tertiaryPalette(ActionTertiaryColors c) => ButtonPalette(
      bgDefault: c.bgDefault,
      bgHover: c.bgHover,
      bgPressed: c.bgPressed,
      bgDisabled: ColorPrimitives.transparent,
      fgDefault: c.fgDefault,
      fgDisabled: c.fgDisabled,
    );

ButtonPalette _destructivePalette(ActionDestructiveColors c) => ButtonPalette(
      bgDefault: c.bgDefault,
      bgHover: c.bgHover,
      bgPressed: c.bgPressed,
      bgDisabled: c.bgDisabled,
      fgDefault: c.fgDefault,
      fgDisabled: c.fgDefault,
    );

ButtonPalette _appleInkPalette() => const ButtonPalette(
      bgDefault: ColorPrimitives.appleInk,
      bgHover: ColorPrimitives.appleInkHover,
      bgPressed: ColorPrimitives.appleInkPressed,
      bgDisabled: ColorPrimitives.appleInkPressed,
      fgDefault: ColorPrimitives.appleCanvas,
      fgDisabled: ColorPrimitives.appleDisabled,
    );

ButtonPalette _appleCanvasPalette() => const ButtonPalette(
      bgDefault: ColorPrimitives.appleCanvas,
      bgHover: ColorPrimitives.appleCanvasHover,
      bgPressed: ColorPrimitives.appleCanvasPressed,
      bgDisabled: ColorPrimitives.appleCanvasPressed,
      fgDefault: ColorPrimitives.appleInk,
      fgDisabled: ColorPrimitives.appleDisabled,
    );
