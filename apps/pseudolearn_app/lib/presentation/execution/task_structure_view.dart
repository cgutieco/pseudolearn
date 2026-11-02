import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/execution/execution_history_command.dart';
import '../../application/execution/execution_history_cubit.dart';
import '../../application/execution/execution_history_state.dart';
import '../../domain/model/execution/task_structure_scene.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class TaskStructureView extends StatelessWidget {
  final ExecutionHistoryState state;

  const TaskStructureView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final scene = context.read<ExecutionHistoryCubit>().projectStructure();
    return ListView(
      children: [
        if (scene.beginsAtRetentionHorizon)
          _RetentionNotice(eventIndex: state.horizonFirst),
        for (final task in scene.tasks)
          _TaskStructureRow(task: task, scene: scene),
      ],
    );
  }
}

final class _RetentionNotice extends StatelessWidget {
  final int eventIndex;

  const _RetentionNotice({required this.eventIndex});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(SpacingTokens.space3),
    child: Semantics(
      liveRegion: true,
      child: AppText(
        AppLocalizations.of(context)!.executionHistoryStartsAt(eventIndex),
        variant: AppTextVariant.bodySmall,
      ),
    ),
  );
}

final class _TaskStructureRow extends StatelessWidget {
  final TaskStructureNode task;
  final TaskStructureScene scene;

  const _TaskStructureRow({required this.task, required this.scene});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = task.taskId == 0
        ? l10n.executionStructureRoot
        : l10n.executionTaskLane(task.taskId);
    return ListTile(
      title: AppText(title, variant: AppTextVariant.bodyDefault),
      subtitle: _TaskStructureDetails(task: task, scene: scene),
      onTap: task.createdAtEvent == null
          ? null
          : () => context.read<ExecutionHistoryCubit>().dispatch(
              SelectHistoryEvent(task.createdAtEvent!),
            ),
    );
  }
}

final class _TaskStructureDetails extends StatelessWidget {
  final TaskStructureNode task;
  final TaskStructureScene scene;

  const _TaskStructureDetails({required this.task, required this.scene});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.executionStructureStatus(_statusLabel(l10n, task.status)),
          variant: AppTextVariant.caption,
        ),
        if (task.outcome != null)
          AppText(
            _outcomeLabel(l10n, task.outcome!),
            variant: AppTextVariant.caption,
          ),
        ..._taskRelationships(task, scene, l10n),
        for (final join in task.joins)
          _TaskJoinLabel(taskId: task.taskId, join: join),
      ],
    );
  }
}

List<Widget> _taskRelationships(
  TaskStructureNode task,
  TaskStructureScene scene,
  AppLocalizations l10n,
) => [
  if (task.parentId != null)
    AppText(
      l10n.executionStructureParent(task.parentId!),
      variant: AppTextVariant.caption,
    )
  else if (task.taskId != 0 && scene.beginsAtRetentionHorizon)
    AppText(
      l10n.executionStructureRelationUnavailable,
      variant: AppTextVariant.caption,
    ),
  if (task.scopeId != null)
    AppText(
      l10n.executionStructureScope(task.scopeId!),
      variant: AppTextVariant.caption,
    ),
];

final class _TaskJoinLabel extends StatelessWidget {
  final int taskId;
  final TaskJoinMarker join;

  const _TaskJoinLabel({required this.taskId, required this.join});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppText(
      l10n.executionJoinLabel(
        taskId,
        join.eventIndex,
        _outcomeLabel(l10n, join.outcome),
      ),
      variant: AppTextVariant.caption,
    );
  }
}

String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
  'created' => l10n.executionStatusCreated,
  'ready' => l10n.executionStatusReady,
  'running' => l10n.executionStatusRunning,
  'suspended' => l10n.executionStatusSuspended,
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

String _outcomeLabel(AppLocalizations l10n, String outcome) =>
    switch (outcome) {
      'success' => l10n.executionTaskOutcomeSuccess,
      'error' || 'failure' => l10n.executionTaskOutcomeError,
      'cancelled' => l10n.executionTaskOutcomeCancelled,
      'cancelled_by_host' => l10n.executionTaskOutcomeCancelledByHost,
      'limit_reached' => l10n.executionTaskOutcomeLimitReached,
      _ => l10n.executionTaskOutcomeReported(outcome),
    };
