import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/library_metrics.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/spacing.dart';
import '../charts/chart_legend.dart';
import '../charts/chart_palette.dart';
import '../charts/chart_reveal.dart';
import '../charts/donut_painter.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';

Color profileColorOf(SyntaxProfileId profileId, ChartPalette palette) =>
    switch (profileId) {
      SyntaxProfileId.classicSpanish => palette.lessons,
      SyntaxProfileId.english => palette.concepts,
    };

final class LibraryCard extends StatelessWidget {
  final LibraryMetrics metrics;

  const LibraryCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardLibraryTitle,
      child: Row(
        children: [
          SizedBox.square(
            dimension: ComponentMetricsTokens.dashboardDonutSize,
            child: _ProfileDonut(metrics: metrics),
          ),
          SizedBox(width: canvas.scaled(SpacingTokens.space4)),
          Expanded(child: _ProfileLegend(metrics: metrics)),
        ],
      ),
    );
  }
}

final class _ProfileLegend extends StatelessWidget {
  final LibraryMetrics metrics;

  const _ProfileLegend({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = ChartPalette.of(context);

    return ChartLegend(
      direction: Axis.vertical,
      entries: [
        for (final profileId in SyntaxProfileId.values)
          LegendEntry(
            label: profileLabelOf(profileId, l10n),
            color: profileColorOf(profileId, palette),
            value: '${metrics.countOf(profileId)}',
          ),
      ],
    );
  }
}

final class _ProfileDonut extends StatelessWidget {
  final LibraryMetrics metrics;

  const _ProfileDonut({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);

    return ChartReveal(
      builder: (context, progress) => CustomPaint(
        painter: DonutPainter(
          slices: [
            for (final profileId in SyntaxProfileId.values)
              DonutSlice(
                value: metrics.countOf(profileId),
                color: profileColorOf(profileId, palette),
              ),
          ],
          trackColor: palette.track,
          stroke: ComponentMetricsTokens.dashboardDonutStroke,
          progress: progress,
        ),
        child: Center(child: _DonutCenter(total: metrics.total)),
      ),
    );
  }
}

final class _DonutCenter extends StatelessWidget {
  final int total;

  const _DonutCenter({required this.total});

  @override
  Widget build(BuildContext context) {
    final text = AppThemeExtension.of(context).colors.text;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          '$total',
          variant: AppTextVariant.heading2,
          color: text.primary,
        ),
        AppText(
          l10n.dashboardStatAlgorithms,
          variant: AppTextVariant.caption,
          color: text.secondary,
        ),
      ],
    );
  }
}
