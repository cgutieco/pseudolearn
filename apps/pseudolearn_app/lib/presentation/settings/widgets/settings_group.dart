import 'package:flutter/widgets.dart';
import '../../components/card/app_card_surface.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/card_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsGroup({super.key, required this.title, required this.items});

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
        AppCardSurface(
          padding: EdgeInsets.symmetric(
              vertical: canvas.scaled(SpacingTokens.space2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CardMetricsTokens.radius),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items),
          ),
        ),
      ],
    );
  }
}
