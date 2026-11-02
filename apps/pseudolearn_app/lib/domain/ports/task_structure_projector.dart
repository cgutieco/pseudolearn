import '../model/execution/execution_history_event.dart';
import '../model/execution/task_structure_scene.dart';

abstract interface class TaskStructureProjector {
  TaskStructureScene project({
    required List<ExecutionHistoryEvent> events,
    required int horizonFirst,
  });
}
