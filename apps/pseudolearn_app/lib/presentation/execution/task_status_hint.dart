import '../../domain/model/execution/task_event_kind.dart';
import '../../domain/model/execution/task_structure_scene.dart';
import '../l10n/generated/app_localizations.dart';
import 'task_labels.dart';

String? taskStatusHint(
  AppLocalizations l10n,
  TaskStructureNode task,
  TaskStructureScene scene,
) {
  final wait = task.wait;
  if (wait != null) return _waitHint(l10n, wait, scene);
  final line = task.currentLine;
  return switch (task.status) {
    'created' => l10n.executionHintCreated,
    'ready' => l10n.executionHintReady,
    'running' when line != null => l10n.executionHintRunning(line),
    _ => _outcomeHint(l10n, task.outcome),
  };
}

String _waitHint(
  AppLocalizations l10n,
  TaskWaitState wait,
  TaskStructureScene scene,
) => switch (wait.cause) {
  TaskWaitCause.task => l10n.executionHintWaitTask(
    taskNamedLabel(l10n, wait.target, scene.nameOf(wait.target)),
  ),
  TaskWaitCause.join => l10n.executionHintWaitJoin(
    wait.pendingChildren,
    wait.totalChildren,
  ),
  TaskWaitCause.channelSend => l10n.executionHintWaitSend(wait.target),
  TaskWaitCause.channelReceive => l10n.executionHintWaitReceive(wait.target),
  TaskWaitCause.select => l10n.executionHintWaitSelect,
  _ => l10n.executionHintWaitEffect,
};

String? _outcomeHint(AppLocalizations l10n, String? outcome) =>
    switch (outcome) {
      null => null,
      'success' => l10n.executionTaskOutcomeSuccess,
      'error' || 'failure' => l10n.executionTaskOutcomeError,
      'cancelled' => l10n.executionTaskOutcomeCancelled,
      'cancelled_by_host' => l10n.executionTaskOutcomeCancelledByHost,
      'limit_reached' => l10n.executionTaskOutcomeLimitReached,
      _ => l10n.executionTaskOutcomeReported(outcome),
    };
