import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/sync_health.dart';
import '../../l10n/generated/app_localizations.dart';
import 'dashboard_card.dart';
import 'dashboard_metric_row.dart';

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String formatSyncDate(DateTime moment) =>
    '${moment.year}-${_twoDigits(moment.month)}-${_twoDigits(moment.day)}';

final class SyncCard extends StatelessWidget {
  final SyncHealth health;
  final DateTime? lastSyncAt;

  const SyncCard({super.key, required this.health, required this.lastSyncAt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardSyncTitle,
      child: _SyncRows(health: health, lastSyncAt: lastSyncAt),
    );
  }
}

final class _SyncRows extends StatelessWidget {
  final SyncHealth health;
  final DateTime? lastSyncAt;

  const _SyncRows({required this.health, required this.lastSyncAt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final moment = lastSyncAt;
    final oldest = health.oldestPendingAgeInDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardMetricRow(
          label: l10n.dashboardSyncLastAt,
          value:
              moment == null ? l10n.dashboardSyncNever : formatSyncDate(moment),
        ),
        DashboardMetricRow(
          label: l10n.dashboardSyncPending,
          value: '${health.pendingCount}',
        ),
        if (oldest != null)
          DashboardMetricRow(
            label: l10n.dashboardSyncOldest,
            value: l10n.dashboardSyncDaysAgo(oldest),
          ),
        DashboardMetricRow(
          label: l10n.dashboardSyncConflicts,
          value: '${health.conflictCount}',
        ),
      ],
    );
  }
}
