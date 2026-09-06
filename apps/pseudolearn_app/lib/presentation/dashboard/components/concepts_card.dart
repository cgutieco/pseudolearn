import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/concept_coverage.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';
import 'dashboard_state_mark.dart';

final class ConceptsCard extends StatelessWidget {
  final ConceptCoverage coverage;

  const ConceptsCard({super.key, required this.coverage});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardConceptsTitle,
      subtitle: l10n.dashboardConceptsSubtitle,
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
          for (final concept in coverage.concepts)
            _ConceptRow(concept: concept),
        ],
      ),
    );
  }
}

final class _ConceptRow extends StatelessWidget {
  final ConceptUsage concept;

  const _ConceptRow({required this.concept});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: canvas.scaled(SpacingTokens.space1)),
      child: Row(
        children: [
          Expanded(
            child: DashboardStateMark(
              isDone: concept.isExercised,
              label: conceptLabelOf(concept.construct, l10n),
            ),
          ),
          SizedBox(width: canvas.scaled(SpacingTokens.space2)),
          AppText(
            l10n.dashboardConceptDocuments(concept.documentCount),
            variant: AppTextVariant.caption,
            color: theme.colors.text.secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
