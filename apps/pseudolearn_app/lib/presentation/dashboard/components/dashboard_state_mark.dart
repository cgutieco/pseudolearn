import 'package:flutter/widgets.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class DashboardStateMark extends StatelessWidget {
  final bool isDone;
  final String label;

  const DashboardStateMark({
    super.key,
    required this.isDone,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final color = isDone
        ? theme.colors.severities.success.fg
        : theme.colors.text.tertiary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ComponentMetricsTokens.dashboardStateDotSize,
          height: ComponentMetricsTokens.dashboardStateDotSize,
          decoration:
              ShapeDecoration(color: color, shape: const CircleBorder()),
        ),
        SizedBox(width: canvas.scaled(SpacingTokens.space2)),
        Flexible(
          child: AppText(
            label,
            variant: AppTextVariant.caption,
            color: color,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
