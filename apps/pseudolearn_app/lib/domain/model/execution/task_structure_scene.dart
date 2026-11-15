import 'task_event_kind.dart';

final class TaskWaitState {
  final TaskWaitCause cause;
  final int target;
  final int pendingChildren;
  final int totalChildren;

  const TaskWaitState({
    required this.cause,
    required this.target,
    this.pendingChildren = 0,
    this.totalChildren = 0,
  });
}

final class TaskStructureNode {
  final int taskId;
  final String? name;
  final int depth;
  final int? parentId;
  final int? scopeId;
  final int? createdAtEvent;
  final int? completedAtEvent;
  final int? currentLine;
  final String status;
  final String? outcome;
  final TaskWaitState? wait;
  final List<int> children;
  final List<TaskJoinMarker> joins;

  TaskStructureNode({
    required this.taskId,
    this.name,
    this.depth = 0,
    required this.parentId,
    required this.scopeId,
    required this.createdAtEvent,
    required this.completedAtEvent,
    this.currentLine,
    required this.status,
    required this.outcome,
    this.wait,
    required List<int> children,
    required List<TaskJoinMarker> joins,
  }) : children = List.unmodifiable(children),
       joins = List.unmodifiable(joins);
}

final class TaskJoinMarker {
  final int taskId;
  final int eventIndex;
  final String outcome;

  const TaskJoinMarker({
    required this.taskId,
    required this.eventIndex,
    required this.outcome,
  });
}

final class TaskStructureScene {
  final List<TaskStructureNode> tasks;
  final bool beginsAtRetentionHorizon;

  TaskStructureScene({
    required List<TaskStructureNode> tasks,
    required this.beginsAtRetentionHorizon,
  }) : tasks = List.unmodifiable(tasks);

  String? nameOf(int taskId) {
    for (final task in tasks) {
      if (task.taskId == taskId) return task.name;
    }
    return null;
  }
}
