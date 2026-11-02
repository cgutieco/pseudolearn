import 'package:flutter/material.dart';
import '../../application/execution/execution_history_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'task_event_selection_controls.dart';
import 'task_event_values_view.dart';

final class TaskEventStateView extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskEventStateView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final inspection = state.inspection;
    if (inspection == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.space4),
          child: AppText(
            AppLocalizations.of(context)!.executionObservationUnavailable,
            variant: AppTextVariant.bodySmall,
          ),
        ),
      );
    }
    return Column(
      children: [
        TaskEventSelectionControls(state: state, inspection: inspection),
        TaskEventValuesHeading(state: state),
        if (state.selectedRecord?.eventClass.startsWith('channel_') ?? false)
          const TaskChannelStateNotice(),
        Expanded(child: TaskEventValuesView(state: state)),
        if (state.canLoadMoreValues) const TaskEventValuePageButton(),
      ],
    );
  }
}
