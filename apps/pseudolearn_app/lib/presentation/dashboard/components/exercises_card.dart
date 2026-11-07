import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/exercise_coverage.dart';
import '../../../domain/model/dashboard/part_coverage.dart';
import '../../../domain/model/route/route_kinds.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'coverage_meter.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';

final class ExercisesCard extends StatelessWidget {
  final ExerciseCoverage coverage;
  final List<PartCoverage> parts;

  const ExercisesCard({super.key, required this.coverage, required this.parts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardExercisesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CoverageMeter(
            label: l10n.dashboardExercisesTitle,
            count: coverage.overall,
          ),
          _PartGroup(coverage: coverage, parts: parts),
          _LevelGroup(coverage: coverage),
          _KindGroup(coverage: coverage),
        ],
      ),
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
      padding: EdgeInsets.only(top: canvas.scaled(SpacingTokens.space3)),
      child: AppText(
        text,
        variant: AppTextVariant.overline,
        color: theme.colors.text.tertiary,
      ),
    );
  }
}

final class _PartGroup extends StatelessWidget {
  final ExerciseCoverage coverage;
  final List<PartCoverage> parts;

  const _PartGroup({required this.coverage, required this.parts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupTitle(text: l10n.dashboardExercisesByTrack),
        for (final part in parts)
          CoverageMeter(
            label: '${part.number} · ${part.title}',
            count: coverage.ofPart(part.partId),
          ),
      ],
    );
  }
}

final class _LevelGroup extends StatelessWidget {
  final ExerciseCoverage coverage;

  const _LevelGroup({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupTitle(text: l10n.dashboardExercisesByLevel),
        for (final level in RouteLevel.values)
          CoverageMeter(
            label: levelLabelOf(level, l10n),
            count: coverage.ofLevel(level),
          ),
      ],
    );
  }
}

final class _KindGroup extends StatelessWidget {
  final ExerciseCoverage coverage;

  const _KindGroup({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupTitle(text: l10n.dashboardExercisesByKind),
        for (final kind in RouteExerciseKind.values)
          CoverageMeter(
            label: kindLabelOf(kind, l10n),
            count: coverage.ofKind(kind),
          ),
      ],
    );
  }
}
