import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/concept_coverage.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/spacing.dart';
import 'chip_cloud.dart';
import 'coverage_chip.dart';
import 'coverage_meter.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';

final class ConceptsCard extends StatelessWidget {
  final ConceptCoverage coverage;

  const ConceptsCard({super.key, required this.coverage});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardConceptsTitle,
      subtitle: l10n.dashboardConceptsSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CoverageMeter(
            label: l10n.dashboardOverviewConcepts,
            count: coverage.count,
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space3)),
          _ConceptChips(coverage: coverage),
        ],
      ),
    );
  }
}

final class _ConceptChips extends StatelessWidget {
  final ConceptCoverage coverage;

  const _ConceptChips({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChipCloud(
      chips: [
        for (final concept in coverage.concepts)
          Semantics(
            label: l10n.dashboardConceptDocuments(concept.documentCount),
            child: CoverageChip(
              label: conceptLabelOf(concept.construct, l10n),
              isDone: concept.isExercised,
              badge: concept.isExercised ? '${concept.documentCount}' : null,
            ),
          ),
      ],
    );
  }
}
