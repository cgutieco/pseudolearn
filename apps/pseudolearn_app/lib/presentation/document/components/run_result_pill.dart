import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'run_outcome.dart';

final class RunResultPill extends StatelessWidget {
  final RunOutcome outcome;
  final VoidCallback? onTap;

  const RunResultPill({super.key, required this.outcome, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = outcome.tone(AppThemeExtension.of(context).colors.severities);
    return Semantics(
      container: true,
      button: onTap != null,
      label: outcome.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: ComponentMetricsTokens.runResultPillHeight,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
          ),
          child: _PillContent(outcome: outcome, color: colors.fg),
        ),
      ),
    );
  }
}

final class _PillContent extends StatelessWidget {
  final RunOutcome outcome;
  final Color color;

  const _PillContent({required this.outcome, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(outcome.icon, size: IconMetricsTokens.iconXs, color: color),
      const SizedBox(width: SpacingTokens.space1),
      AppText(
        outcome.label,
        variant: AppTextVariant.caption,
        color: color,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
