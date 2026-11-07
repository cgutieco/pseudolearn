import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class ReferenceCodeFrame extends StatelessWidget {
  final String label;
  final Widget child;

  const ReferenceCodeFrame({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      padding: const EdgeInsets.all(SpacingTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: AppTextVariant.overline,
            color: theme.colors.text.tertiary,
          ),
          const SizedBox(height: SpacingTokens.space2),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
        ],
      ),
    );
  }
}
