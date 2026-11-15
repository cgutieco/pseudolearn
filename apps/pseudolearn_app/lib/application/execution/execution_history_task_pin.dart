import '../../domain/model/execution/execution_history_event.dart';
import 'execution_history_state.dart';

int inspectedTaskAt(ExecutionHistoryState state, ExecutionHistoryEvent event) {
  if (!state.taskPinned) return event.taskId;
  final pinned = state.selectedTaskId;
  if (pinned == 0) return pinned;
  for (final record in state.events) {
    if (record.index > event.index) break;
    if (record.eventClass == 'task_spawned' && record.data['task'] == pinned) {
      return pinned;
    }
  }
  return event.taskId;
}
