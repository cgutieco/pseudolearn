import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/part_coverage.dart';
import '../../l10n/generated/app_localizations.dart';
import 'coverage_meter.dart';
import 'dashboard_card.dart';

final class LearningRouteCard extends StatelessWidget {
  final List<PartCoverage> parts;

  const LearningRouteCard({super.key, required this.parts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardRouteTitle,
      subtitle: l10n.dashboardRouteSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final part in parts)
            CoverageMeter(
              label: '${part.number} · ${part.title}',
              count: part.lessons,
            ),
        ],
      ),
    );
  }
}
