import 'package:flutter/material.dart';
import '../../../domain/model/export/target_language_id.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/color_primitives.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class TargetLanguageSelector extends StatelessWidget {
  final TargetLanguageId selectedLanguage;
  final ValueChanged<TargetLanguageId> onLanguageSelected;

  const TargetLanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final border = Border.all(
      color: theme.colors.borders.subtle,
      width: BorderMetricsTokens.widthHairline,
    );

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.space1),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: border,
      ),
      child: _SelectorRow(
        selectedLanguage: selectedLanguage,
        onLanguageSelected: onLanguageSelected,
        pythonLabel: l10n.targetLanguagePython,
        rustLabel: l10n.targetLanguageRust,
      ),
    );
  }
}

final class _SelectorRow extends StatelessWidget {
  final TargetLanguageId selectedLanguage;
  final ValueChanged<TargetLanguageId> onLanguageSelected;
  final String pythonLabel;
  final String rustLabel;

  const _SelectorRow({
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.pythonLabel,
    required this.rustLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LanguageSegment(
          label: pythonLabel,
          isSelected: selectedLanguage == TargetLanguageId.python,
          onTap: () => onLanguageSelected(TargetLanguageId.python),
        ),
        const SizedBox(width: SpacingTokens.space1),
        _LanguageSegment(
          label: rustLabel,
          isSelected: selectedLanguage == TargetLanguageId.rust,
          onTap: () => onLanguageSelected(TargetLanguageId.rust),
        ),
      ],
    );
  }
}

final class _LanguageSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final backgroundColor = isSelected
        ? theme.colors.surfaces.defaultSurface
        : ColorPrimitives.transparent;
    final textColor = isSelected
        ? theme.colors.text.primary
        : theme.colors.text.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.space3,
          vertical: SpacingTokens.space1,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.label,
          color: textColor,
        ),
      ),
    );
  }
}
