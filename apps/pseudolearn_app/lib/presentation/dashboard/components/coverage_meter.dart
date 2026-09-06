import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/coverage_count.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class CoverageMeter extends StatelessWidget {
  final String label;
  final CoverageCount count;

  const CoverageMeter({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: canvas.scaled(SpacingTokens.space1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MeterHeader(label: label, count: count),
          SizedBox(height: canvas.scaled(SpacingTokens.space1)),
          _MeterTrack(ratio: count.ratio, isComplete: count.isComplete),
        ],
      ),
    );
  }
}

final class _MeterHeader extends StatelessWidget {
  final String label;
  final CoverageCount count;

  const _MeterHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: canvas.scaled(SpacingTokens.space2)),
        AppText(
          l10n.dashboardCoverageRatio(count.done, count.total),
          variant: AppTextVariant.caption,
          color: theme.colors.text.primary,
        ),
      ],
    );
  }
}

final class _MeterTrack extends StatelessWidget {
  final double ratio;
  final bool isComplete;

  const _MeterTrack({required this.ratio, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final fill = isComplete
        ? theme.colors.severities.success.fg
        : theme.colors.actions.primary.bgDefault;

    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
      child: Container(
        height: ComponentMetricsTokens.dashboardMeterHeight,
        color: theme.colors.surfaces.subtle,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: ratio.clamp(0, 1),
          child: ColoredBox(color: fill),
        ),
      ),
    );
  }
}
