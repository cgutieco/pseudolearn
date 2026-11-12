import '../../domain/model/execution/execution_history_event.dart';
import 'task_event_classifier.dart';

final class TaskSpawnRecord {
  final int child;
  final int parent;
  final int scope;
  final int eventIndex;

  const TaskSpawnRecord({
    required this.child,
    required this.parent,
    required this.scope,
    required this.eventIndex,
  });
}

final class TaskSpawnRegistry {
  final List<TaskSpawnRecord> records;

  const TaskSpawnRegistry._(this.records);

  factory TaskSpawnRegistry.from(List<ExecutionHistoryEvent> ordered) {
    final records = <TaskSpawnRecord>[];
    for (final event in ordered) {
      if (event.eventClass != 'task_spawned') continue;
      final child = TaskEventClassifier.integer(event.data['task']);
      final parent = TaskEventClassifier.integer(event.data['parent']);
      final scope = TaskEventClassifier.integer(event.data['scope']);
      if (child == null || parent == null || scope == null) continue;
      records.add(
        TaskSpawnRecord(
          child: child,
          parent: parent,
          scope: scope,
          eventIndex: event.index,
        ),
      );
    }
    return TaskSpawnRegistry._(List.unmodifiable(records));
  }

  List<int> childrenOf({
    required int parent,
    required int scope,
    required int before,
  }) => [
    for (final record in records)
      if (record.parent == parent &&
          record.scope == scope &&
          record.eventIndex < before)
        record.child,
  ];
}
