import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/specification_coverage.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'dashboard_card.dart';
import 'dashboard_state_mark.dart';

final class SpecificationCard extends StatelessWidget {
  final SpecificationCoverage coverage;

  const SpecificationCard({super.key, required this.coverage});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardSpecificationTitle,
      subtitle: l10n.dashboardSpecificationSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            l10n.dashboardCoverageRatio(
              coverage.count.done,
              coverage.count.total,
            ),
            variant: AppTextVariant.heading3,
            color: theme.colors.text.primary,
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space3)),
          for (final section in coverage.sections)
            _SectionRow(section: section),
        ],
      ),
    );
  }
}

final class _SectionRow extends StatelessWidget {
  final SpecificationSectionCoverage section;

  const _SectionRow({required this.section});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = section.isExercised
        ? l10n.dashboardSpecificationExercised
        : l10n.dashboardSpecificationPending;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: canvas.scaled(SpacingTokens.space1)),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              section.title,
              variant: AppTextVariant.bodySmall,
              color: theme.colors.text.primary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: canvas.scaled(SpacingTokens.space2)),
          DashboardStateMark(isDone: section.isExercised, label: state),
        ],
      ),
    );
  }
}
