import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/track_coverage.dart';
import '../../l10n/generated/app_localizations.dart';
import 'coverage_meter.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';

final class LearningRouteCard extends StatelessWidget {
  final List<TrackCoverage> tracks;

  const LearningRouteCard({super.key, required this.tracks});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardRouteTitle,
      subtitle: l10n.dashboardRouteSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final track in tracks)
            CoverageMeter(
              label: trackLabelOf(track.track, l10n),
              count: track.modules,
            ),
        ],
      ),
    );
  }
}
