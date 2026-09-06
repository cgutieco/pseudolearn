import 'package:flutter/widgets.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class OnboardingStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          title,
          variant: AppTextVariant.heading2,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space2)),
        AppText(
          subtitle,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.secondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
