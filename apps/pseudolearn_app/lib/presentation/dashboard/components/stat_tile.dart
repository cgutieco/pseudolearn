import 'package:flutter/widgets.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class StatTile extends StatelessWidget {
  final String value;
  final String label;

  const StatTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final text = theme.colors.text;
    final surface = BoxDecoration(
      color: theme.colors.surfaces.subtle,
      borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
    );

    return Container(
      padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space3)),
      decoration: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(value, variant: AppTextVariant.heading3, color: text.primary),
          AppText(
            label,
            variant: AppTextVariant.caption,
            color: text.secondary,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
