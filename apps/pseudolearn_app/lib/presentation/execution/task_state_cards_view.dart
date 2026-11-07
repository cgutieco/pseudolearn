import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';
import 'task_state_card.dart';

final class TaskStateCardsView extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskStateCardsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final scene = context.read<ExecutionHistoryCubit>().projectStructure();
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.space3),
      children: [
        if (scene.beginsAtRetentionHorizon)
          _RetentionNotice(eventIndex: state.horizonFirst),
        for (final task in scene.tasks)
          TaskStateCard(
            task: task,
            scene: scene,
            isEventTask: task.taskId == state.selectedRecord?.taskId,
          ),
      ],
    );
  }
}

final class _RetentionNotice extends StatelessWidget {
  final int eventIndex;

  const _RetentionNotice({required this.eventIndex});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
    child: Semantics(
      liveRegion: true,
      child: AppText(
        AppLocalizations.of(context)!.executionHistoryStartsAt(eventIndex),
        variant: AppTextVariant.bodySmall,
      ),
    ),
  );
}
