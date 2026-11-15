import 'package:flutter/widgets.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../charts/chart_palette.dart';
import '../charts/chart_reveal.dart';
import '../charts/ring_painter.dart';

final class OverviewRings extends StatelessWidget {
  final DashboardState state;

  const OverviewRings({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);
    final rings = [
      RingTrack(ratio: state.lessons.ratio, color: palette.lessons),
      RingTrack(ratio: state.exercises.overall.ratio, color: palette.exercises),
      RingTrack(ratio: state.concepts.count.ratio, color: palette.concepts),
    ];

    return Center(
      child: SizedBox.square(
        dimension: ComponentMetricsTokens.dashboardHeroRingSize,
        child: ChartReveal(
          builder: (context, progress) => CustomPaint(
            painter: ConcentricRingsPainter(
              rings: rings,
              trackColor: palette.track,
              stroke: ComponentMetricsTokens.dashboardHeroRingStroke,
              gap: ComponentMetricsTokens.dashboardHeroRingGap,
              progress: progress,
            ),
            child: Center(
              child: _RouteShare(ratio: state.lessons.ratio * progress),
            ),
          ),
        ),
      ),
    );
  }
}

final class _RouteShare extends StatelessWidget {
  final double ratio;

  const _RouteShare({required this.ratio});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          l10n.dashboardPercent((ratio * 100).round()),
          variant: AppTextVariant.heading2,
          color: theme.colors.text.primary,
        ),
        AppText(
          l10n.dashboardOverviewRouteCaption,
          variant: AppTextVariant.caption,
          color: theme.colors.text.secondary,
        ),
      ],
    );
  }
}
