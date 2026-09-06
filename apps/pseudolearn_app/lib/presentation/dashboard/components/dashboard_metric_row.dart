import 'package:flutter/widgets.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class DashboardMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const DashboardMetricRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: canvas.scaled(SpacingTokens.space1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppText(
              label,
              variant: AppTextVariant.bodySmall,
              color: theme.colors.text.secondary,
            ),
          ),
          SizedBox(width: canvas.scaled(SpacingTokens.space3)),
          Flexible(
            child: AppText(
              value,
              variant: AppTextVariant.label,
              color: theme.colors.text.primary,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
