import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/task_event_kind.dart';

final class TaskEventClassifier {
  const TaskEventClassifier._();

  static const Map<String, TaskEventKind> _kinds = {
    'task_spawned': TaskEventKind.spawn,
    'task_ready': TaskEventKind.ready,
    'task_resumed': TaskEventKind.resume,
    'task_suspended': TaskEventKind.suspend,
    'task_completed': TaskEventKind.complete,
    'task_cancel_requested': TaskEventKind.cancelRequest,
    'scope_joined': TaskEventKind.join,
    'channel_created': TaskEventKind.channelCreate,
    'channel_sent': TaskEventKind.channelSend,
    'channel_received': TaskEventKind.channelReceive,
    'channel_closed': TaskEventKind.channelClose,
    'effect_delivered': TaskEventKind.effectDelivered,
    'call': TaskEventKind.call,
    'return': TaskEventKind.callReturn,
    'decision': TaskEventKind.decision,
    'output': TaskEventKind.output,
    'input_requested': TaskEventKind.input,
    'input_received': TaskEventKind.input,
    'failure': TaskEventKind.failure,
    'statement_entered': TaskEventKind.statementEnter,
    'statement_exited': TaskEventKind.statementExit,
  };

  static const Map<String, TaskWaitCause> _causes = {
    'task': TaskWaitCause.task,
    'join': TaskWaitCause.join,
    'channel_send': TaskWaitCause.channelSend,
    'channel_receive': TaskWaitCause.channelReceive,
    'select': TaskWaitCause.select,
    'effect': TaskWaitCause.effect,
  };

  static TaskEventKind kindOf(ExecutionHistoryEvent event) {
    final kind = _kinds[event.eventClass] ?? TaskEventKind.other;
    final receivedNothing = event.data['present'] == false;
    return kind == TaskEventKind.channelReceive && receivedNothing
        ? TaskEventKind.channelEmpty
        : kind;
  }

  static TaskWaitCause waitCauseOf(ExecutionHistoryEvent event) =>
      _causes[event.data['cause']] ?? TaskWaitCause.unknown;

  static List<ExecutionHistoryEvent> ordered(
    List<ExecutionHistoryEvent> events,
  ) =>
      events.toList()..sort((left, right) => left.index.compareTo(right.index));

  static Map<int, String> taskNames(List<ExecutionHistoryEvent> ordered) {
    final names = <int, String>{};
    for (final event in ordered) {
      final name = event.data['nombre'];
      if (event.eventClass == 'call' && name is String && event.taskId != 0) {
        names.putIfAbsent(event.taskId, () => name);
      }
    }
    return names;
  }

  static int? integer(Object? value) =>
      value is int && value >= 0 ? value : null;
}
