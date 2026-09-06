import 'package:flutter/material.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/button_metrics.dart';
import '../../theme/tokens/color_primitives.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/motion.dart';
import '../../theme/tokens/radii.dart';
import 'button_palette.dart';

final class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final AppButtonVariant variant;
  final bool destructive;
  final VoidCallback? onPressed;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.variant,
    this.destructive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final palette = ButtonPalette.forVariant(
      theme.colors.actions,
      variant,
      destructive: destructive,
      isDark: theme.isDark,
    );
    final minSize = canvas.scaled(ButtonMetricsTokens.buttonIconOnlyMinSize);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: IconMetricsTokens.iconSm),
      tooltip: semanticLabel,
      style: _styleFor(theme, palette, minSize)
          .copyWith(animationDuration: canvas.motion(MotionSpeed.fast)),
    );
  }
}

ButtonStyle _styleFor(AppThemeExtension theme, ButtonPalette palette, double minSize) {
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size.square(minSize)),
    fixedSize: WidgetStatePropertyAll(Size.square(minSize)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(RadiusTokens.radiusSm)),
    ),
    backgroundColor: WidgetStateProperty.resolveWith(palette.background),
    foregroundColor: WidgetStateProperty.resolveWith(palette.foreground),
    overlayColor: const WidgetStatePropertyAll(ColorPrimitives.transparent),
    mouseCursor: _cursorFor(),
    elevation: const WidgetStatePropertyAll(0),
    side: WidgetStateProperty.resolveWith((states) => _sideFor(theme, palette, states)),
    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
  );
}

BorderSide? _sideFor(AppThemeExtension theme, ButtonPalette palette, Set<WidgetState> states) {
  if (states.contains(WidgetState.focused)) {
    return BorderSide(color: theme.colors.borders.focus, width: BorderMetricsTokens.focusRingWidth);
  }
  final borderColor = palette.border(states);
  if (borderColor == null) return null;
  return BorderSide(color: borderColor, width: BorderMetricsTokens.widthHairline);
}

WidgetStateProperty<MouseCursor> _cursorFor() {
  return WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.disabled)
        ? SystemMouseCursors.basic
        : SystemMouseCursors.click,
  );
}
