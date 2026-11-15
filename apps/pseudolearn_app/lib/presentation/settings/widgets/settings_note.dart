import 'package:flutter/widgets.dart';
import '../../components/card/app_card.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

final class SettingsNote extends StatelessWidget {
  final String title;
  final String text;

  const SettingsNote({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(title,
            variant: AppTextVariant.label, color: theme.colors.text.secondary),
        SizedBox(height: canvas.scaled(SpacingTokens.space2)),
        AppCard(
          child: AppText(
            text,
            variant: AppTextVariant.bodyDefault,
            color: theme.colors.text.secondary,
          ),
        ),
      ],
    );
  }
}
