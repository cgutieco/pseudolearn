import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class DemoBriefCard extends StatelessWidget {
  const DemoBriefCard({super.key});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space3)),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.brandSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BriefLabel(label: l10n.onboardingLabBriefTitle),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          AppText(
            l10n.onboardingLabBriefStatement,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.primary,
          ),
        ],
      ),
    );
  }
}

final class _BriefLabel extends StatelessWidget {
  final String label;

  const _BriefLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Row(
      children: [
        Icon(
          Icons.assignment_outlined,
          size: IconMetricsTokens.iconSm,
          color: theme.colors.actions.primary.bgDefault,
        ),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.overline,
            color: theme.colors.actions.primary.bgDefault,
          ),
        ),
      ],
    );
  }
}
