import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/coverage_count.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/spacing.dart';
import '../charts/chart_palette.dart';
import '../charts/chart_reveal.dart';
import '../charts/ring_painter.dart';

final class LevelGauge extends StatelessWidget {
  final String label;
  final CoverageCount count;

  const LevelGauge({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox.square(
          dimension: ComponentMetricsTokens.dashboardGaugeSize,
          child: _GaugeRing(count: count),
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space1)),
        AppText(
          label,
          variant: AppTextVariant.label,
          color: theme.colors.text.primary,
          maxLines: 1,
        ),
        AppText(
          l10n.dashboardCoverageRatio(count.done, count.total),
          variant: AppTextVariant.caption,
          color: theme.colors.text.secondary,
        ),
      ],
    );
  }
}

final class _GaugeRing extends StatelessWidget {
  final CoverageCount count;

  const _GaugeRing({required this.count});

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = count.isComplete ? palette.exercises : palette.lessons;

    return ChartReveal(
      builder: (context, progress) => CustomPaint(
        painter: ConcentricRingsPainter(
          rings: [RingTrack(ratio: count.ratio, color: color)],
          trackColor: palette.track,
          stroke: ComponentMetricsTokens.dashboardGaugeStroke,
          gap: 0,
          progress: progress,
        ),
        child: Center(
          child: AppText(
            l10n.dashboardPercent((count.ratio * progress * 100).round()),
            variant: AppTextVariant.label,
            color: theme.colors.text.primary,
          ),
        ),
      ),
    );
  }
}
