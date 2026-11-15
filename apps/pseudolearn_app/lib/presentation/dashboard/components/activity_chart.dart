import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/activity_timeline.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/spacing.dart';
import '../charts/chart_palette.dart';
import '../charts/chart_reveal.dart';
import '../charts/stacked_bars_painter.dart';

final class ActivityChart extends StatelessWidget {
  final ActivityTimeline timeline;

  const ActivityChart({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Bars(timeline: timeline),
        SizedBox(height: canvas.scaled(SpacingTokens.space1)),
        _WeekLabels(timeline: timeline),
      ],
    );
  }
}

final class _Bars extends StatelessWidget {
  final ActivityTimeline timeline;

  const _Bars({required this.timeline});

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);
    final columns = [
      for (final week in timeline.weeks)
        StackedColumn([
          week.modulesVisited,
          week.exercisesCompleted,
          week.documentsCreated,
        ]),
    ];

    return SizedBox(
      height: ComponentMetricsTokens.dashboardStackedChartHeight,
      child: ChartReveal(
        builder: (context, progress) => CustomPaint(
          painter: StackedBarsPainter(
            columns: columns,
            colors: [palette.lessons, palette.exercises, palette.creations],
            baselineColor: palette.track,
            peak: timeline.peakTotalEvents,
            progress: progress,
          ),
        ),
      ),
    );
  }
}

final class _WeekLabels extends StatelessWidget {
  final ActivityTimeline timeline;

  const _WeekLabels({required this.timeline});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        for (final week in timeline.weeks)
          Expanded(
            child: Semantics(
              label:
                  '${l10n.dashboardWeekOf(week.weekStart.day, week.weekStart.month)}: ${week.totalEvents}',
              excludeSemantics: true,
              child: AppText(
                '${week.weekStart.day}/${week.weekStart.month}',
                variant: AppTextVariant.caption,
                color: theme.colors.text.tertiary,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
      ],
    );
  }
}
