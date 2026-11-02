import '../model/execution/execution_history_event.dart';
import '../model/execution/task_flow_scene.dart';

abstract interface class TaskFlowProjector {
  TaskFlowScene project({
    required List<ExecutionHistoryEvent> events,
    required int rangeStart,
    required int rangeEnd,
    required double width,
  });
}
