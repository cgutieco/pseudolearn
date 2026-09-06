import 'package:flutter/widgets.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/card_metrics.dart';
import '../../theme/tokens/motion.dart';

final class AppCardSurface extends StatelessWidget {
  final EdgeInsets padding;
  final bool elevated;
  final bool focused;
  final Widget child;

  const AppCardSurface({
    super.key,
    required this.padding,
    this.elevated = false,
    this.focused = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final borderColor = focused
        ? theme.colors.borders.focus
        : theme.colors.borders.defaultBorder;
    final borderWidth = focused
        ? BorderMetricsTokens.focusRingWidth
        : BorderMetricsTokens.widthHairline;

    return AnimatedContainer(
      duration: canvas.motion(MotionSpeed.fast),
      curve: MotionTokens.easeStandard,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(CardMetricsTokens.radius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: elevated ? theme.elevation.level2 : theme.elevation.level1,
      ),
      child: child,
    );
  }
}
