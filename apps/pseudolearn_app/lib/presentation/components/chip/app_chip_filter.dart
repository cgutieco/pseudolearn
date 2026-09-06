import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../typography/app_text.dart';

final class AppChipFilter extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppChipFilter({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        child: _ChipContainer(
          label: label,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

final class _ChipContainer extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _ChipContainer({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final bg = isSelected ? theme.colors.surfaces.brandSubtle : theme.colors.surfaces.defaultSurface;
    final border = isSelected ? theme.colors.actions.secondary.borderDefault : theme.colors.borders.strong;
    final text = isSelected ? theme.colors.actions.secondary.fgDefault : theme.colors.text.primary;

    return Container(
      height: ComponentMetricsTokens.chipFilterHeight,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            Icon(Icons.check, size: IconMetricsTokens.iconXs, color: text),
            const SizedBox(width: SpacingTokens.space1),
          ],
          AppText(label, variant: AppTextVariant.label, color: text),
        ],
      ),
    );
  }
}
