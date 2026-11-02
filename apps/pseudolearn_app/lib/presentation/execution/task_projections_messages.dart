import 'package:flutter/material.dart';
import '../../application/execution/execution_history_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class TaskHistoryEmptyMessage extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskHistoryEmptyMessage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = state.error == 'observation_unavailable'
        ? l10n.executionObservationUnavailable
        : l10n.executionHistoryEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.space6),
        child: AppText(message, variant: AppTextVariant.bodyDefault),
      ),
    );
  }
}

final class TaskHistoryError extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskHistoryError({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = state.error == 'observation_unavailable'
        ? l10n.executionObservationUnavailable
        : l10n.executionHistoryError;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space4,
        vertical: SpacingTokens.space1,
      ),
      child: Semantics(
        liveRegion: true,
        child: AppText(message, variant: AppTextVariant.bodySmall),
      ),
    );
  }
}
