import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/coverage_count.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../charts/chart_palette.dart';

final class RequiredExercisesStrip extends StatelessWidget {
  final CoverageCount count;

  const RequiredExercisesStrip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasRequired = count.total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasRequired) ...[
          AppText(
            l10n.dashboardNextStepRequired(count.done, count.total),
            variant: AppTextVariant.label,
            color: theme.colors.text.primary,
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          _Segments(count: count),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
        ],
        AppText(
          hasRequired
              ? l10n.dashboardNextStepRequiredHint
              : l10n.dashboardNextStepVisitHint,
          variant: AppTextVariant.caption,
          color: theme.colors.text.secondary,
        ),
      ],
    );
  }
}

final class _Segments extends StatelessWidget {
  final CoverageCount count;

  const _Segments({required this.count});

  @override
  Widget build(BuildContext context) {
    final gap = DesignCanvasScope.of(context).scaled(SpacingTokens.space1);
    final palette = ChartPalette.of(context);

    return Row(
      children: [
        for (var index = 0; index < count.total; index++) ...[
          if (index > 0) SizedBox(width: gap),
          Expanded(
            child: Container(
              height: ComponentMetricsTokens.dashboardMeterHeight,
              decoration: BoxDecoration(
                color: index < count.done ? palette.exercises : palette.track,
                borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
