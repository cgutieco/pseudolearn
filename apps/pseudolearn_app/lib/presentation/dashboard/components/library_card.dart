import 'package:flutter/widgets.dart';
import '../../../domain/model/dashboard/library_metrics.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';
import 'dashboard_metric_row.dart';

final class LibraryCard extends StatelessWidget {
  final LibraryMetrics metrics;

  const LibraryCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DashboardCard(
      title: l10n.dashboardLibraryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TotalCreated(total: metrics.total),
          SizedBox(height: canvas.scaled(SpacingTokens.space3)),
          for (final profileId in SyntaxProfileId.values)
            DashboardMetricRow(
              label: profileLabelOf(profileId, l10n),
              value: '${metrics.countOf(profileId)}',
            ),
        ],
      ),
    );
  }
}

final class _TotalCreated extends StatelessWidget {
  final int total;

  const _TotalCreated({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          '$total',
          variant: AppTextVariant.display,
          color: theme.colors.text.primary,
        ),
        AppText(
          l10n.dashboardLibraryTotal,
          variant: AppTextVariant.bodySmall,
          color: theme.colors.text.secondary,
        ),
      ],
    );
  }
}
