import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/exercise_coverage.dart';
import '../../../domain/model/route/route_kinds.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../charts/chart_palette.dart';
import '../charts/chart_reveal.dart';
import '../charts/radar_painter.dart';
import 'dashboard_labels.dart';

final class SkillsRadar extends StatelessWidget {
  final ExerciseCoverage coverage;

  const SkillsRadar({super.key, required this.coverage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ComponentMetricsTokens.dashboardRadarMaxSize,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(child: _RadarPlot(coverage: coverage)),
              for (final (index, kind) in RouteExerciseKind.values.indexed)
                _AxisLabel(kind: kind, coverage: coverage, index: index),
            ],
          ),
        ),
      ),
    );
  }
}

final class _RadarPlot extends StatelessWidget {
  final ExerciseCoverage coverage;

  const _RadarPlot({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);
    final ratios = [
      for (final kind in RouteExerciseKind.values) coverage.ofKind(kind).ratio,
    ];

    return ChartReveal(
      builder: (context, progress) => CustomPaint(
        painter: RadarPainter(
          ratios: ratios,
          inset: ComponentMetricsTokens.dashboardRadarLabelInset,
          rings: ComponentMetricsTokens.dashboardRadarRings,
          gridColor: palette.track,
          fillColor: palette.lessons,
          progress: progress,
        ),
      ),
    );
  }
}

final class _AxisLabel extends StatelessWidget {
  final RouteExerciseKind kind;
  final ExerciseCoverage coverage;
  final int index;

  const _AxisLabel({
    required this.kind,
    required this.coverage,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppThemeExtension.of(context).colors.text;
    final l10n = AppLocalizations.of(context)!;
    final angle =
        -math.pi / 2 + 2 * math.pi * index / RouteExerciseKind.values.length;
    final count = coverage.ofKind(kind);
    final label = kindLabelOf(kind, l10n);

    return Align(
      alignment: Alignment(math.cos(angle), math.sin(angle)),
      child: Semantics(
        label:
            '$label: ${l10n.dashboardCoverageRatio(count.done, count.total)}',
        excludeSemantics: true,
        child: SizedBox(
          width: ComponentMetricsTokens.dashboardRadarLabelWidth,
          child: AppText(
            label,
            variant: AppTextVariant.caption,
            color: count.done > 0 ? text.primary : text.tertiary,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
