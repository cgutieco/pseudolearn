import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/activity_timeline.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../charts/chart_legend.dart';
import '../charts/chart_palette.dart';
import 'activity_chart.dart';
import 'dashboard_card.dart';

final class ActivityCard extends StatelessWidget {
  final ActivityTimeline timeline;

  const ActivityCard({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardActivityTitle,
      subtitle: l10n.dashboardActivitySubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            l10n.dashboardActivityActiveWeeks(
              timeline.activeWeeks,
              timeline.weeks.length,
            ),
            variant: AppTextVariant.label,
            color: theme.colors.text.primary,
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space3)),
          ActivityChart(timeline: timeline),
          SizedBox(height: canvas.scaled(SpacingTokens.space3)),
          const _ActivityLegend(),
        ],
      ),
    );
  }
}

final class _ActivityLegend extends StatelessWidget {
  const _ActivityLegend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = ChartPalette.of(context);

    return ChartLegend(
      entries: [
        LegendEntry(
          label: l10n.dashboardActivityLessons,
          color: palette.lessons,
        ),
        LegendEntry(
          label: l10n.dashboardActivityExercises,
          color: palette.exercises,
        ),
        LegendEntry(
          label: l10n.dashboardActivityCreations,
          color: palette.creations,
        ),
      ],
    );
  }
}
