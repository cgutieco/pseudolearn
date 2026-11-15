import 'dart:ui';
import 'color_primitives.dart';

final class ActionPrimaryColors {
  final Color bgDefault, bgHover, bgPressed, bgDisabled, fgDefault, fgDisabled;

  const ActionPrimaryColors.light()
      : bgDefault = ColorPrimitives.brand700,
        bgHover = ColorPrimitives.brand800,
        bgPressed = ColorPrimitives.brand900,
        bgDisabled = ColorPrimitives.neutral200,
        fgDefault = ColorPrimitives.neutral0,
        fgDisabled = ColorPrimitives.neutral500;

  const ActionPrimaryColors.dark()
      : bgDefault = ColorPrimitives.brand400,
        bgHover = ColorPrimitives.brand300,
        bgPressed = ColorPrimitives.brand200,
        bgDisabled = ColorPrimitives.neutral800,
        fgDefault = ColorPrimitives.neutral1000,
        fgDisabled = ColorPrimitives.neutral600;

  const ActionPrimaryColors.of({
    required this.bgDefault,
    required this.bgHover,
    required this.bgPressed,
    required this.bgDisabled,
    required this.fgDefault,
    required this.fgDisabled,
  });

  static ActionPrimaryColors lerp(ActionPrimaryColors a, ActionPrimaryColors b, double t) => ActionPrimaryColors.of(
    bgDefault: Color.lerp(a.bgDefault, b.bgDefault, t)!,
    bgHover: Color.lerp(a.bgHover, b.bgHover, t)!,
    bgPressed: Color.lerp(a.bgPressed, b.bgPressed, t)!,
    bgDisabled: Color.lerp(a.bgDisabled, b.bgDisabled, t)!,
    fgDefault: Color.lerp(a.fgDefault, b.fgDefault, t)!,
    fgDisabled: Color.lerp(a.fgDisabled, b.fgDisabled, t)!,
  );

}

final class ActionSecondaryColors {
  final Color bgDefault, bgHover, bgPressed, bgDisabled, borderDefault, borderDisabled, fgDefault, fgDisabled;

  const ActionSecondaryColors.light()
      : bgDefault = ColorPrimitives.neutral0,
        bgHover = ColorPrimitives.brand50,
        bgPressed = ColorPrimitives.brand100,
        bgDisabled = ColorPrimitives.neutral50,
        borderDefault = ColorPrimitives.neutral500,
        borderDisabled = ColorPrimitives.neutral200,
        fgDefault = ColorPrimitives.brand700,
        fgDisabled = ColorPrimitives.neutral500;

  const ActionSecondaryColors.dark()
      : bgDefault = ColorPrimitives.neutral900,
        bgHover = ColorPrimitives.brand950,
        bgPressed = ColorPrimitives.brand900,
        bgDisabled = ColorPrimitives.neutral950,
        borderDefault = ColorPrimitives.neutral500,
        borderDisabled = ColorPrimitives.neutral800,
        fgDefault = ColorPrimitives.brand300,
        fgDisabled = ColorPrimitives.neutral600;

  const ActionSecondaryColors.of({
    required this.bgDefault,
    required this.bgHover,
    required this.bgPressed,
    required this.bgDisabled,
    required this.borderDefault,
    required this.borderDisabled,
    required this.fgDefault,
    required this.fgDisabled,
  });

  static ActionSecondaryColors lerp(ActionSecondaryColors a, ActionSecondaryColors b, double t) => ActionSecondaryColors.of(
    bgDefault: Color.lerp(a.bgDefault, b.bgDefault, t)!,
    bgHover: Color.lerp(a.bgHover, b.bgHover, t)!,
    bgPressed: Color.lerp(a.bgPressed, b.bgPressed, t)!,
    bgDisabled: Color.lerp(a.bgDisabled, b.bgDisabled, t)!,
    borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
    borderDisabled: Color.lerp(a.borderDisabled, b.borderDisabled, t)!,
    fgDefault: Color.lerp(a.fgDefault, b.fgDefault, t)!,
    fgDisabled: Color.lerp(a.fgDisabled, b.fgDisabled, t)!,
  );

}

final class ActionTertiaryColors {
  final Color bgDefault, bgHover, bgPressed, fgDefault, fgDisabled;

  const ActionTertiaryColors.light()
      : bgDefault = ColorPrimitives.transparent,
        bgHover = ColorPrimitives.neutral100,
        bgPressed = ColorPrimitives.neutral200,
        fgDefault = ColorPrimitives.brand700,
        fgDisabled = ColorPrimitives.neutral500;

  const ActionTertiaryColors.dark()
      : bgDefault = ColorPrimitives.transparent,
        bgHover = ColorPrimitives.neutral800,
        bgPressed = ColorPrimitives.neutral700,
        fgDefault = ColorPrimitives.brand300,
        fgDisabled = ColorPrimitives.neutral600;

  const ActionTertiaryColors.of({
    required this.bgDefault,
    required this.bgHover,
    required this.bgPressed,
    required this.fgDefault,
    required this.fgDisabled,
  });

  static ActionTertiaryColors lerp(ActionTertiaryColors a, ActionTertiaryColors b, double t) => ActionTertiaryColors.of(
    bgDefault: Color.lerp(a.bgDefault, b.bgDefault, t)!,
    bgHover: Color.lerp(a.bgHover, b.bgHover, t)!,
    bgPressed: Color.lerp(a.bgPressed, b.bgPressed, t)!,
    fgDefault: Color.lerp(a.fgDefault, b.fgDefault, t)!,
    fgDisabled: Color.lerp(a.fgDisabled, b.fgDisabled, t)!,
  );

}

final class ActionDestructiveColors {
  final Color bgDefault, bgHover, bgPressed, bgDisabled, fgDefault;

  const ActionDestructiveColors.light()
      : bgDefault = ColorPrimitives.red700,
        bgHover = ColorPrimitives.red800,
        bgPressed = ColorPrimitives.red900,
        bgDisabled = ColorPrimitives.neutral200,
        fgDefault = ColorPrimitives.neutral0;

  const ActionDestructiveColors.dark()
      : bgDefault = ColorPrimitives.red400,
        bgHover = ColorPrimitives.red300,
        bgPressed = ColorPrimitives.red200,
        bgDisabled = ColorPrimitives.neutral800,
        fgDefault = ColorPrimitives.neutral1000;

  const ActionDestructiveColors.of({
    required this.bgDefault,
    required this.bgHover,
    required this.bgPressed,
    required this.bgDisabled,
    required this.fgDefault,
  });

  static ActionDestructiveColors lerp(ActionDestructiveColors a, ActionDestructiveColors b, double t) => ActionDestructiveColors.of(
    bgDefault: Color.lerp(a.bgDefault, b.bgDefault, t)!,
    bgHover: Color.lerp(a.bgHover, b.bgHover, t)!,
    bgPressed: Color.lerp(a.bgPressed, b.bgPressed, t)!,
    bgDisabled: Color.lerp(a.bgDisabled, b.bgDisabled, t)!,
    fgDefault: Color.lerp(a.fgDefault, b.fgDefault, t)!,
  );

}

final class ActionColors {
  final ActionPrimaryColors primary;
  final ActionSecondaryColors secondary;
  final ActionTertiaryColors tertiary;
  final ActionDestructiveColors destructive;

  const ActionColors.light()
      : primary = const ActionPrimaryColors.light(),
        secondary = const ActionSecondaryColors.light(),
        tertiary = const ActionTertiaryColors.light(),
        destructive = const ActionDestructiveColors.light();

  const ActionColors.dark()
      : primary = const ActionPrimaryColors.dark(),
        secondary = const ActionSecondaryColors.dark(),
        tertiary = const ActionTertiaryColors.dark(),
        destructive = const ActionDestructiveColors.dark();

  const ActionColors.of({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.destructive,
  });

  static ActionColors lerp(ActionColors a, ActionColors b, double t) => ActionColors.of(
    primary: ActionPrimaryColors.lerp(a.primary, b.primary, t),
    secondary: ActionSecondaryColors.lerp(a.secondary, b.secondary, t),
    tertiary: ActionTertiaryColors.lerp(a.tertiary, b.tertiary, t),
    destructive: ActionDestructiveColors.lerp(a.destructive, b.destructive, t),
  );

}
