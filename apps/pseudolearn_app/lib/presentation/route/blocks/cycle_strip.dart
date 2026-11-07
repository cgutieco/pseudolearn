import 'package:flutter/material.dart';
import '../../../domain/model/route/lesson_block.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import '../route_labels.dart';

final class CycleStrip extends StatelessWidget {
  final List<int> active;

  const CycleStrip({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SpacingTokens.space1,
      runSpacing: SpacingTokens.space1,
      children: [
        for (final phase in routePhases)
          CyclePhaseChip(phase: phase, active: active.contains(phase)),
      ],
    );
  }
}

final class CyclePhaseChip extends StatelessWidget {
  final int phase;
  final bool active;

  const CyclePhaseChip({super.key, required this.phase, required this.active});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final color = routePhaseColor(phase, theme);
    final label = routePhaseLabel(phase, AppLocalizations.of(context)!);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.space1,
      ),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.16) : theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.caption,
        color: active ? color : theme.colors.text.tertiary,
      ),
    );
  }
}

final class PhaseHeadingView extends StatelessWidget {
  final PhaseHeadingLessonBlock heading;
  final LessonScope scope;

  const PhaseHeadingView({super.key, required this.heading, required this.scope});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final phase = heading.phases.isEmpty ? 1 : heading.phases.first;
    return Row(
      children: [
        PhaseBadge(phases: heading.phases, color: routePhaseColor(phase, theme)),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(
          child: LessonRunsText(
            runs: heading.runs,
            scope: scope,
            variant: AppTextVariant.heading3,
          ),
        ),
      ],
    );
  }
}

final class PhaseBadge extends StatelessWidget {
  final List<int> phases;
  final Color color;

  const PhaseBadge({super.key, required this.phases, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.space1,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
      ),
      child: AppText(
        phases.join('-'),
        variant: AppTextVariant.label,
        color: AppThemeExtension.of(context).colors.surfaces.defaultSurface,
      ),
    );
  }
}
