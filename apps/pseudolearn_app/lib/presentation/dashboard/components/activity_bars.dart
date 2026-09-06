import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/activity_timeline.dart';
import '../../../domain/model/dashboard/activity_week.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

enum ActivityMeasure { learning, creations }

int activityValueOf(ActivityWeek week, ActivityMeasure measure) =>
    switch (measure) {
      ActivityMeasure.learning => week.learningEvents,
      ActivityMeasure.creations => week.documentsCreated,
    };

int activityPeakOf(ActivityTimeline timeline, ActivityMeasure measure) =>
    switch (measure) {
      ActivityMeasure.learning => timeline.peakLearningEvents,
      ActivityMeasure.creations => timeline.peakDocumentsCreated,
    };

final class ActivityBars extends StatelessWidget {
  final ActivityTimeline timeline;
  final ActivityMeasure measure;

  const ActivityBars({
    super.key,
    required this.timeline,
    required this.measure,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final peak = activityPeakOf(timeline, measure);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final week in timeline.weeks)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: canvas.scaled(SpacingTokens.spaceHalf),
              ),
              child: _ActivityColumn(
                week: week,
                value: activityValueOf(week, measure),
                peak: peak,
              ),
            ),
          ),
      ],
    );
  }
}

final class _ActivityColumn extends StatelessWidget {
  final ActivityWeek week;
  final int value;
  final int peak;

  const _ActivityColumn({
    required this.week,
    required this.value,
    required this.peak,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final weekLabel =
        l10n.dashboardWeekOf(week.weekStart.day, week.weekStart.month);

    return Semantics(
      label: '$weekLabel: $value',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActivityBar(value: value, peak: peak),
          SizedBox(height: canvas.scaled(SpacingTokens.space1)),
          AppText(
            '${week.weekStart.day}/${week.weekStart.month}',
            variant: AppTextVariant.caption,
            color: theme.colors.text.tertiary,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }
}

final class _ActivityBar extends StatelessWidget {
  final int value;
  final int peak;

  const _ActivityBar({required this.value, required this.peak});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    const maxHeight = ComponentMetricsTokens.dashboardBarMaxHeight;
    const baseline = ComponentMetricsTokens.dashboardBarBaselineHeight;
    final filled = peak == 0 ? baseline : maxHeight * value / peak;

    return SizedBox(
      height: maxHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: filled < baseline ? baseline : filled,
            decoration: BoxDecoration(
              color: value == 0
                  ? theme.colors.surfaces.subtle
                  : theme.colors.actions.primary.bgDefault,
              borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
            ),
          ),
        ],
      ),
    );
  }
}
