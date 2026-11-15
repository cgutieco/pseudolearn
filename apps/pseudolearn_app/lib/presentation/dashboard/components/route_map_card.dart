import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/part_coverage.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../charts/chart_legend.dart';
import '../charts/chart_palette.dart';
import 'dashboard_card.dart';
import '../../../domain/model/dashboard/lesson_mark.dart';
import 'lesson_trail.dart';

final class RouteMapCard extends StatelessWidget {
  final List<PartCoverage> parts;
  final ValueChanged<String> onOpenModule;

  const RouteMapCard({
    super.key,
    required this.parts,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final palette = ChartPalette.of(context);

    return DashboardCard(
      title: l10n.dashboardRouteTitle,
      subtitle: l10n.dashboardRouteSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final part in parts)
            _PartTrack(part: part, onOpenModule: onOpenModule),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          ChartLegend(
            entries: [
              for (final stage in LessonStage.values.reversed)
                LegendEntry(
                  label: lessonStageLabelOf(stage, l10n),
                  color: lessonFillOf(stage, palette),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _PartTrack extends StatelessWidget {
  final PartCoverage part;
  final ValueChanged<String> onOpenModule;

  const _PartTrack({required this.part, required this.onOpenModule});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: canvas.scaled(SpacingTokens.space4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PartHeader(part: part),
          SizedBox(height: canvas.scaled(SpacingTokens.space2)),
          LessonTrail(marks: part.marks, onOpenModule: onOpenModule),
        ],
      ),
    );
  }
}

final class _PartHeader extends StatelessWidget {
  final PartCoverage part;

  const _PartHeader({required this.part});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: AppText(
            '${part.number} · ${part.title}',
            variant: AppTextVariant.label,
            color: theme.colors.text.primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppText(
          l10n.dashboardCoverageRatio(part.lessons.done, part.lessons.total),
          variant: AppTextVariant.caption,
          color: theme.colors.text.secondary,
        ),
      ],
    );
  }
}
