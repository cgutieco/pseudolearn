import 'package:material_ui/material_ui.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/icon_metrics.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';

final class TaskStatusBadge extends StatelessWidget {
  final String status;

  const TaskStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeExtension.of(context).colors;
    final style = _TaskStatusStyle.of(status, colors);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space2,
        vertical: SpacingTokens.spaceHalf,
      ),
      decoration: BoxDecoration(
        color: style.colors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
        border: Border.all(color: style.colors.border),
      ),
      child: _BadgeContent(status: status, style: style),
    );
  }
}

final class _BadgeContent extends StatelessWidget {
  final String status;
  final _TaskStatusStyle style;

  const _BadgeContent({required this.status, required this.style});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(style.icon, size: IconMetricsTokens.iconXs, color: style.colors.fg),
      const SizedBox(width: SpacingTokens.space1),
      AppText(
        taskStatusLabel(AppLocalizations.of(context)!, status),
        variant: AppTextVariant.caption,
        maxLines: 1,
      ),
    ],
  );
}

final class _TaskStatusStyle {
  final IconData icon;
  final SeverityItemColors colors;

  const _TaskStatusStyle(this.icon, this.colors);

  factory _TaskStatusStyle.of(String status, AppSemanticColors palette) {
    final severities = palette.severities;
    return switch (status) {
      'running' => _TaskStatusStyle(Icons.play_arrow, severities.info),
      'ready' || 'created' => _TaskStatusStyle(Icons.schedule, severities.hint),
      'suspended' || 'cancellationRequested' => _TaskStatusStyle(
        Icons.pause,
        severities.warning,
      ),
      'completed' => _TaskStatusStyle(Icons.check, severities.success),
      'cancelled' => _TaskStatusStyle(Icons.block, severities.hint),
      _ => _TaskStatusStyle(Icons.error_outline, severities.error),
    };
  }
}

String taskStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'created' => l10n.executionStatusCreated,
      'ready' => l10n.executionStatusReady,
      'running' => l10n.executionStatusRunning,
      'suspended' => l10n.executionStatusWaiting,
      'completed' => l10n.executionStatusCompleted,
      'cancellationRequested' => l10n.executionStatusCancellationRequested,
      'failed' => l10n.executionStatusFailed,
      'cancelled' => l10n.executionStatusCancelled,
      'cancelledByHost' => l10n.executionStatusCancelledByHost,
      'interruptedByFailure' => l10n.executionStatusInterruptedByFailure,
      'interruptedByHost' => l10n.executionStatusInterruptedByHost,
      'limitReached' => l10n.executionStatusLimitReached,
      'interruptedByLimit' => l10n.executionStatusInterruptedByLimit,
      _ => status,
    };
