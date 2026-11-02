final class TaskStructureNode {
  final int taskId;
  final int? parentId;
  final int? scopeId;
  final int? createdAtEvent;
  final int? completedAtEvent;
  final String status;
  final String? outcome;
  final List<int> children;
  final List<TaskJoinMarker> joins;

  TaskStructureNode({
    required this.taskId,
    required this.parentId,
    required this.scopeId,
    required this.createdAtEvent,
    required this.completedAtEvent,
    required this.status,
    required this.outcome,
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
}
