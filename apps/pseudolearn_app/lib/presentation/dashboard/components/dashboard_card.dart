import 'package:flutter/widgets.dart';
import '../../components/card/app_card.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const DashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final caption = subtitle;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            title,
            variant: AppTextVariant.heading4,
            color: theme.colors.text.primary,
          ),
          if (caption != null) ...[
            SizedBox(height: canvas.scaled(SpacingTokens.space1)),
            AppText(
              caption,
              variant: AppTextVariant.caption,
              color: theme.colors.text.secondary,
            ),
          ],
          SizedBox(height: canvas.scaled(SpacingTokens.space4)),
          child,
        ],
      ),
    );
  }
}
