import '../../domain/model/execution/task_event_kind.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../l10n/generated/app_localizations.dart';

typedef TaskLabeler = String Function(int taskId);

String taskEventSentence(
  AppLocalizations l10n,
  TaskFlowRow row,
  TaskLabeler label,
) {
  final task = label(row.taskId);
  return switch (row.kind) {
    TaskEventKind.suspend => _waitSentence(l10n, row, label: label),
    TaskEventKind.channelCreate ||
    TaskEventKind.channelSend ||
    TaskEventKind.channelReceive ||
    TaskEventKind.channelEmpty ||
    TaskEventKind.channelClose => _channelSentence(l10n, row, task),
    TaskEventKind.spawn ||
    TaskEventKind.ready ||
    TaskEventKind.resume ||
    TaskEventKind.complete ||
    TaskEventKind.cancelRequest ||
    TaskEventKind.join ||
    TaskEventKind.effectDelivered => _lifecycleSentence(
      l10n,
      row,
      label: label,
    ),
    _ => _codeSentence(l10n, row, task),
  };
}

String _lifecycleSentence(
  AppLocalizations l10n,
  TaskFlowRow row, {
  required TaskLabeler label,
}) {
  final task = label(row.taskId);
  return switch (row.kind) {
    TaskEventKind.spawn => l10n.executionSentenceSpawn(
      task,
      label(row.relatedTaskId ?? row.taskId),
    ),
    TaskEventKind.ready => l10n.executionSentenceReady(task),
    TaskEventKind.resume => l10n.executionSentenceResume(task),
    TaskEventKind.complete => _completionSentence(l10n, row, task),
    TaskEventKind.cancelRequest => l10n.executionSentenceCancelRequest(task),
    TaskEventKind.join => l10n.executionSentenceJoin(task),
    _ => l10n.executionSentenceEffect(task),
  };
}

String _completionSentence(
  AppLocalizations l10n,
  TaskFlowRow row,
  String task,
) => switch (row.detail) {
  'error' => l10n.executionSentenceCompleteError(task),
  'cancelled' => l10n.executionSentenceCancelled(task),
  _ => l10n.executionSentenceComplete(task),
};

String _waitSentence(
  AppLocalizations l10n,
  TaskFlowRow row, {
  required TaskLabeler label,
}) {
  final task = label(row.taskId);
  final channel = row.channelId ?? 0;
  return switch (row.waitCause) {
    TaskWaitCause.task => l10n.executionSentenceWaitTask(
      task,
      label(row.relatedTaskId ?? row.taskId),
    ),
    TaskWaitCause.join => l10n.executionSentenceWaitJoin(task),
    TaskWaitCause.channelSend => l10n.executionSentenceWaitSend(task, channel),
    TaskWaitCause.channelReceive => l10n.executionSentenceWaitReceive(
      task,
      channel,
    ),
    TaskWaitCause.select => l10n.executionSentenceWaitSelect(task),
    TaskWaitCause.effect => l10n.executionSentenceWaitEffect(task),
    _ => l10n.executionSentenceWaitOther(task),
  };
}

String _channelSentence(AppLocalizations l10n, TaskFlowRow row, String task) {
  final channel = row.channelId ?? 0;
  return switch (row.kind) {
    TaskEventKind.channelCreate => l10n.executionSentenceChannelCreate(
      task,
      channel,
    ),
    TaskEventKind.channelSend => l10n.executionSentenceChannelSend(
      task,
      channel,
    ),
    TaskEventKind.channelReceive => l10n.executionSentenceChannelReceive(
      task,
      channel,
    ),
    TaskEventKind.channelEmpty => l10n.executionSentenceChannelEmpty(
      task,
      channel,
    ),
    _ => l10n.executionSentenceChannelClose(task, channel),
  };
}

String _codeSentence(AppLocalizations l10n, TaskFlowRow row, String task) {
  final line = row.event.line;
  final detail = row.detail ?? '';
  return switch (row.kind) {
    TaskEventKind.call => l10n.executionSentenceCall(task, detail),
    TaskEventKind.callReturn => l10n.executionSentenceReturn(task, detail),
    TaskEventKind.output => l10n.executionSentenceOutput(task, detail),
    TaskEventKind.input => l10n.executionSentenceInput(task),
    TaskEventKind.failure => l10n.executionSentenceFailure(task),
    TaskEventKind.statementEnter => l10n.executionSentenceEnter(task, line),
    TaskEventKind.statementExit => l10n.executionSentenceExit(task, line),
    TaskEventKind.decision => l10n.executionSentenceDecision(task, line),
    _ => l10n.executionSentenceOther(task, line),
  };
}
