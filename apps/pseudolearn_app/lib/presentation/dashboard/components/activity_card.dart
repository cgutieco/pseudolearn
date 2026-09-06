import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/activity_timeline.dart';
import '../../l10n/generated/app_localizations.dart';
import 'activity_bars.dart';
import 'dashboard_card.dart';

final class ActivityCard extends StatelessWidget {
  final ActivityTimeline timeline;

  const ActivityCard({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardActivityTitle,
      subtitle: l10n.dashboardActivitySubtitle,
      child: ActivityBars(
        timeline: timeline,
        measure: ActivityMeasure.learning,
      ),
    );
  }
}
