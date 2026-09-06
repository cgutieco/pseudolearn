import 'package:flutter/material.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/button_metrics.dart';
import '../../theme/tokens/color_primitives.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/motion.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../typography/app_text.dart';
import 'button_palette.dart';

export 'button_palette.dart' show AppButtonVariant;

final class AppButton extends StatelessWidget {
  final String label;
  final AppButtonVariant variant;
  final bool destructive;
  final IconData? icon;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.label,
    required this.variant,
    this.destructive = false,
    this.icon,
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
    final style = _styleFor(
      theme: theme,
      palette: palette,
      horizontalPadding: canvas.scaled(SpacingTokens.space3),
      minWidth: canvas.scaled(ButtonMetricsTokens.buttonMinWidth),
    ).copyWith(animationDuration: canvas.motion(MotionSpeed.fast));

    return TextButton(
      onPressed: onPressed,
      style: style,
      child: _ButtonContent(label: label, icon: icon, iconGap: canvas.scaled(SpacingTokens.space1)),
    );
  }
}

final class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final double iconGap;

  const _ButtonContent({required this.label, required this.icon, required this.iconGap});

  @override
  Widget build(BuildContext context) {
    final labelStyle = resolveAppTextStyle(context, AppTextVariant.label);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: IconMetricsTokens.iconSm),
          SizedBox(width: iconGap),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textScaler: resolveAppTextScaler(AppTextVariant.label),
          ),
        ),
      ],
    );
  }
}

ButtonStyle _styleFor({
  required AppThemeExtension theme,
  required ButtonPalette palette,
  required double horizontalPadding,
  required double minWidth,
}) {
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(minWidth, SpacingTokens.targetTouchMin)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: horizontalPadding)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(RadiusTokens.radiusMd)),
    ),
    backgroundColor: WidgetStateProperty.resolveWith(palette.background),
    foregroundColor: WidgetStateProperty.resolveWith(palette.foreground),
    overlayColor: const WidgetStatePropertyAll(ColorPrimitives.transparent),
    mouseCursor: _cursorFor(),
    elevation: const WidgetStatePropertyAll(0),
    side: WidgetStateProperty.resolveWith((states) => _sideFor(theme, palette, states)),
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
