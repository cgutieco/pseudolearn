import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/exercise_coverage.dart';
import '../../../domain/model/route/route_kinds.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';
import 'level_gauge.dart';
import 'skills_radar.dart';

final class ExercisesCard extends StatelessWidget {
  final ExerciseCoverage coverage;

  const ExercisesCard({super.key, required this.coverage});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardExercisesTitle,
      subtitle: l10n.dashboardExercisesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Headline(coverage: coverage),
          _GroupTitle(text: l10n.dashboardExercisesByLevel),
          _LevelRow(coverage: coverage),
          _GroupTitle(text: l10n.dashboardExercisesByKind),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          SkillsRadar(coverage: coverage),
        ],
      ),
    );
  }
}

final class _Headline extends StatelessWidget {
  final ExerciseCoverage coverage;

  const _Headline({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          l10n.dashboardCoverageRatio(
            coverage.overall.done,
            coverage.overall.total,
          ),
          variant: AppTextVariant.heading2,
          color: theme.colors.text.primary,
        ),
        if (coverage.assisted > 0)
          AppText(
            l10n.dashboardExercisesAssisted(coverage.assisted),
            variant: AppTextVariant.caption,
            color: theme.colors.text.secondary,
          ),
      ],
    );
  }
}

final class _LevelRow extends StatelessWidget {
  final ExerciseCoverage coverage;

  const _LevelRow({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        for (final level in RouteLevel.values)
          Expanded(
            child: LevelGauge(
              label: levelLabelOf(level, l10n),
              count: coverage.ofLevel(level),
            ),
          ),
      ],
    );
  }
}

final class _GroupTitle extends StatelessWidget {
  final String text;

  const _GroupTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: canvas.scaled(SpacingTokens.space4),
        bottom: canvas.scaled(SpacingTokens.space2),
      ),
      child: AppText(
        text,
        variant: AppTextVariant.overline,
        color: theme.colors.text.tertiary,
      ),
    );
  }
}
