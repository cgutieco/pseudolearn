import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/task_structure_scene.dart';
import '../../domain/ports/task_structure_projector.dart';

final class TaskStructureProjection implements TaskStructureProjector {
  const TaskStructureProjection();

  @override
  TaskStructureScene project({
    required List<ExecutionHistoryEvent> events,
    required int horizonFirst,
    List<ExecutionTaskContext> taskContexts = const [],
  }) {
    final tasks = <int, _MutableTask>{0: _MutableTask.root()};
    final orderedEvents = events.toList()
      ..sort((left, right) => left.index.compareTo(right.index));
    for (final event in orderedEvents) {
      if (event.eventClass == 'task_spawned') {
        _recordSpawn(tasks, event);
      }
      if (event.eventClass == 'task_ready') {
        _recordStatus(tasks, event, 'ready');
      }
      if (event.eventClass == 'task_resumed') {
        _recordStatus(tasks, event, 'running');
      }
      if (event.eventClass == 'task_suspended') {
        _recordStatus(tasks, event, 'suspended');
      }
      if (event.eventClass == 'task_completed') _recordCompletion(tasks, event);
      if (event.eventClass == 'task_cancel_requested') {
        _recordStatus(tasks, event, 'cancellationRequested');
      }
      if (event.eventClass == 'scope_joined') _recordJoin(tasks, event);
    }
    _recordObservedStatuses(tasks, taskContexts);
    return TaskStructureScene(
      tasks: _orderedTasks(tasks),
      beginsAtRetentionHorizon: horizonFirst > 0,
    );
  }

  void _recordObservedStatuses(
    Map<int, _MutableTask> tasks,
    List<ExecutionTaskContext> contexts,
  ) {
    for (final context in contexts) {
      tasks[context.taskId]?.observe(context.status, context.completionOutcome);
    }
  }

  void _recordSpawn(Map<int, _MutableTask> tasks, ExecutionHistoryEvent event) {
    final child = _integer(event.data['task']);
    final parent = _integer(event.data['parent']);
    final scope = _integer(event.data['scope']);
    if (child == null || parent == null || tasks.containsKey(child)) return;
    final task = _MutableTask(
      taskId: child,
      parentId: tasks.containsKey(parent) ? parent : null,
      scopeId: scope,
      createdAtEvent: event.index,
    );
    tasks[child] = task;
    tasks[parent]?.children.add(child);
  }

  void _recordCompletion(
    Map<int, _MutableTask> tasks,
    ExecutionHistoryEvent event,
  ) {
    final taskId = _integer(event.data['task']);
    if (taskId == null) return;
    tasks[taskId]?.complete(event.index, event.data['outcome'] as String?);
  }

  void _recordStatus(
    Map<int, _MutableTask> tasks,
    ExecutionHistoryEvent event,
    String status,
  ) {
    final taskId = _integer(event.data['task']);
    if (taskId == null) return;
    tasks[taskId]?.status = status;
  }

  void _recordJoin(Map<int, _MutableTask> tasks, ExecutionHistoryEvent event) {
    final outcome = event.data['outcome'];
    if (outcome is! String) return;
    tasks[event.taskId]?.joins.add(
      TaskJoinMarker(
        taskId: event.taskId,
        eventIndex: event.index,
        outcome: outcome,
      ),
    );
  }
}

List<TaskStructureNode> _orderedTasks(Map<int, _MutableTask> tasks) {
  final ordered = tasks.values.toList()
    ..sort((left, right) => left.taskId.compareTo(right.taskId));
  return [for (final task in ordered) task.snapshot()];
}

final class _MutableTask {
  final int taskId;
  final int? parentId;
  final int? scopeId;
  final int? createdAtEvent;
  int? completedAtEvent;
  String status;
  String? outcome;
  final List<int> children = [];
  final List<TaskJoinMarker> joins = [];

  _MutableTask({
    required this.taskId,
    required this.parentId,
    required this.scopeId,
    required this.createdAtEvent,
  }) : status = 'created';

  factory _MutableTask.root() => _MutableTask(
    taskId: 0,
    parentId: null,
    scopeId: null,
    createdAtEvent: null,
  )..status = 'running';

  void complete(int event, String? result) {
    completedAtEvent = event;
    status = result == 'cancelled' ? 'cancelled' : 'completed';
    outcome = result;
  }

  void observe(ExecutionTaskStatus nextStatus, String? result) {
    status = nextStatus.name;
    outcome = result;
  }

  TaskStructureNode snapshot() => TaskStructureNode(
    taskId: taskId,
    parentId: parentId,
    scopeId: scopeId,
    createdAtEvent: createdAtEvent,
    completedAtEvent: completedAtEvent,
    status: status,
    outcome: outcome,
    children: children,
    joins: joins,
  );
}

int? _integer(Object? value) => value is int && value >= 0 ? value : null;
