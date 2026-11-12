import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/specification_coverage.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/spacing.dart';
import 'chip_cloud.dart';
import 'coverage_chip.dart';
import 'coverage_meter.dart';
import 'dashboard_card.dart';

final class SpecificationCard extends StatelessWidget {
  final SpecificationCoverage coverage;

  const SpecificationCard({super.key, required this.coverage});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardSpecificationTitle,
      subtitle: l10n.dashboardSpecificationSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CoverageMeter(
            label: l10n.dashboardSpecificationSections,
            count: coverage.count,
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space3)),
          _SectionChips(coverage: coverage),
        ],
      ),
    );
  }
}

final class _SectionChips extends StatelessWidget {
  final SpecificationCoverage coverage;

  const _SectionChips({required this.coverage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChipCloud(
      chips: [
        for (final section in coverage.sections)
          Semantics(
            label: section.isExercised
                ? l10n.dashboardSpecificationExercised
                : l10n.dashboardSpecificationPending,
            child: CoverageChip(
              label: section.title,
              isDone: section.isExercised,
            ),
          ),
      ],
    );
  }
}
