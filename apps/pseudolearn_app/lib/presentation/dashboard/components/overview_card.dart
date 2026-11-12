import 'package:flutter/widgets.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/spacing.dart';
import '../charts/chart_legend.dart';
import '../charts/chart_palette.dart';
import 'dashboard_card.dart';
import 'overview_rings.dart';
import 'stat_tile.dart';

final class OverviewCard extends StatelessWidget {
  final DashboardState state;

  const OverviewCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardOverviewTitle,
      subtitle: l10n.dashboardOverviewSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OverviewRings(state: state),
          SizedBox(height: canvas.scaled(SpacingTokens.space4)),
          Center(child: _OverviewLegend(state: state)),
          SizedBox(height: canvas.scaled(SpacingTokens.space4)),
          _StatStrip(state: state),
        ],
      ),
    );
  }
}

final class _OverviewLegend extends StatelessWidget {
  final DashboardState state;

  const _OverviewLegend({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = ChartPalette.of(context);
    final lessons = state.lessons;
    final exercises = state.exercises.overall;
    final concepts = state.concepts.count;

    return ChartLegend(
      entries: [
        LegendEntry(
          label: l10n.dashboardOverviewLessons,
          color: palette.lessons,
          value: l10n.dashboardCoverageRatio(lessons.done, lessons.total),
        ),
        LegendEntry(
          label: l10n.dashboardOverviewExercises,
          color: palette.exercises,
          value: l10n.dashboardCoverageRatio(exercises.done, exercises.total),
        ),
        LegendEntry(
          label: l10n.dashboardOverviewConcepts,
          color: palette.concepts,
          value: l10n.dashboardCoverageRatio(concepts.done, concepts.total),
        ),
      ],
    );
  }
}

final class _StatStrip extends StatelessWidget {
  final DashboardState state;

  const _StatStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final gap = DesignCanvasScope.of(context).scaled(SpacingTokens.space2);
    final l10n = AppLocalizations.of(context)!;
    final activity = state.activity;
    final weeks = l10n.dashboardCoverageRatio(
      activity.activeWeeks,
      activity.weeks.length,
    );
    final tiles = [
      ('${state.library.total}', l10n.dashboardStatAlgorithms),
      (weeks, l10n.dashboardStatActiveWeeks),
      ('${state.exercises.assisted}', l10n.dashboardStatAssisted),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (index > 0) SizedBox(width: gap),
          Expanded(
            child: StatTile(value: tile.$1, label: tile.$2),
          ),
        ],
      ],
    );
  }
}
