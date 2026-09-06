import 'package:flutter/material.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/color_primitives.dart';
import '../../theme/tokens/dialog_metrics.dart';
import '../typography/app_text.dart';

List<Widget> _withGaps(List<Widget> children, double gap) {
  final result = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    if (index > 0) result.add(SizedBox(width: gap));
    result.add(children[index]);
  }
  return result;
}

Future<T?> showAppDialog<T>(BuildContext context, {required WidgetBuilder builder}) {
  final theme = AppThemeExtension.of(context);
  return showDialog<T>(
    context: context,
    barrierColor: ColorPrimitives.neutral1000.withValues(alpha: theme.colors.opacities.scrim),
    builder: builder,
  );
}

final class AppDialog extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String body;
  final List<Widget> actions;

  const AppDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    required this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Dialog(
      backgroundColor: theme.colors.surfaces.overlay,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DialogMetricsTokens.radius)),
      constraints: const BoxConstraints(
        minWidth: DialogMetricsTokens.minWidth,
        maxWidth: DialogMetricsTokens.maxWidth,
      ),
      child: _DialogContent(dialog: this),
    );
  }
}

final class _DialogContent extends StatelessWidget {
  final AppDialog dialog;

  const _DialogContent({required this.dialog});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final padding = canvas.scaled(DialogMetricsTokens.padding);
    final actionsGap = canvas.scaled(DialogMetricsTokens.actionsGap);
    final icon = dialog.icon;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: DialogMetricsTokens.iconSize, color: dialog.iconColor ?? theme.colors.text.secondary),
            const SizedBox(height: DialogMetricsTokens.gapTitleToBody),
          ],
          AppText(dialog.title, variant: AppTextVariant.heading2, color: theme.colors.text.primary),
          const SizedBox(height: DialogMetricsTokens.gapTitleToBody),
          AppText(dialog.body, variant: AppTextVariant.bodyDefault, color: theme.colors.text.primary),
          const SizedBox(height: DialogMetricsTokens.gapBodyToActions),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: _withGaps(dialog.actions, actionsGap)),
        ],
      ),
    );
  }
}
