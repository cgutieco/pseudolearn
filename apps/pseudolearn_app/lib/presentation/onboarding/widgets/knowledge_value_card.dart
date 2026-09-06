import 'package:flutter/material.dart';
import '../../components/card/app_card.dart';
import '../../components/typography/app_text.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class KnowledgeValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> facts;

  const KnowledgeValueCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.facts,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(icon: icon, title: title),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          AppText(
            description,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.secondary,
          ),
          if (facts.isNotEmpty) ...[
            SizedBox(height: canvas.scaled(SpacingTokens.space3)),
            Wrap(
              spacing: SpacingTokens.space2,
              runSpacing: SpacingTokens.space2,
              children: [
                for (final fact in facts) _FactPill(label: fact),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

final class _CardHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: IconMetricsTokens.iconMd,
          color: theme.colors.actions.primary.bgDefault,
        ),
        const SizedBox(width: SpacingTokens.space3),
        Expanded(
          child: AppText(
            title,
            variant: AppTextVariant.heading4,
            color: theme.colors.text.primary,
          ),
        ),
      ],
    );
  }
}

final class _FactPill extends StatelessWidget {
  final String label;

  const _FactPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space1,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.brandSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.caption,
        color: theme.colors.actions.primary.bgDefault,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
