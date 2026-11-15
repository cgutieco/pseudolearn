import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/task_event_kind.dart';
import '../../domain/model/execution/task_structure_scene.dart';
import '../../domain/ports/task_structure_projector.dart';
import 'task_event_classifier.dart';
import 'task_structure_record.dart';

final class TaskStructureProjection implements TaskStructureProjector {
  const TaskStructureProjection();

  @override
  TaskStructureScene project({
    required List<ExecutionHistoryEvent> events,
    required int horizonFirst,
    int? selectedEvent,
    int? liveEvent,
    List<ExecutionTaskContext> taskContexts = const [],
  }) {
    final ordered = TaskEventClassifier.ordered(events);
    final tasks = <int, TaskStructureRecord>{0: TaskStructureRecord.root()};
    for (final event in ordered) {
      if (selectedEvent != null && event.index > selectedEvent) break;
      _apply(tasks, event);
    }
    final isLive =
        selectedEvent == null ||
        liveEvent == null ||
        selectedEvent >= liveEvent;
    if (isLive) _observe(tasks, taskContexts);
    return TaskStructureScene(
      tasks: _depthFirst(tasks, TaskEventClassifier.taskNames(ordered)),
      beginsAtRetentionHorizon: horizonFirst > 0,
    );
  }

  void _apply(
    Map<int, TaskStructureRecord> tasks,
    ExecutionHistoryEvent event,
  ) {
    final kind = TaskEventClassifier.kindOf(event);
    final subject = tasks[TaskEventClassifier.integer(event.data['task'])];
    switch (kind) {
      case TaskEventKind.spawn:
        _recordSpawn(tasks, event);
      case TaskEventKind.ready:
        subject?.changeStatus('ready');
      case TaskEventKind.resume:
        subject?.changeStatus('running');
      case TaskEventKind.suspend:
        subject?.suspend(
          TaskEventClassifier.waitCauseOf(event),
          TaskEventClassifier.integer(event.data['target']),
        );
      case TaskEventKind.complete:
        subject?.complete(event.index, event.data['outcome'] as String?);
      case TaskEventKind.cancelRequest:
        subject?.changeStatus('cancellationRequested');
      case TaskEventKind.join:
        _recordJoin(tasks, event);
      default:
        tasks[event.taskId]?.currentLine = event.line;
    }
  }

  void _observe(
    Map<int, TaskStructureRecord> tasks,
    List<ExecutionTaskContext> contexts,
  ) {
    for (final context in contexts) {
      tasks[context.taskId]?.observe(context.status, context.completionOutcome);
    }
  }

  void _recordSpawn(
    Map<int, TaskStructureRecord> tasks,
    ExecutionHistoryEvent event,
  ) {
    final child = TaskEventClassifier.integer(event.data['task']);
    final parent = TaskEventClassifier.integer(event.data['parent']);
    if (child == null || parent == null || tasks.containsKey(child)) return;
    tasks[child] = TaskStructureRecord(
      taskId: child,
      parentId: tasks.containsKey(parent) ? parent : null,
      scopeId: TaskEventClassifier.integer(event.data['scope']),
      createdAtEvent: event.index,
    );
    tasks[parent]?.children.add(child);
  }

  void _recordJoin(
    Map<int, TaskStructureRecord> tasks,
    ExecutionHistoryEvent event,
  ) {
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

  List<TaskStructureNode> _depthFirst(
    Map<int, TaskStructureRecord> tasks,
    Map<int, String> names,
  ) {
    final nodes = <TaskStructureNode>[];
    void visit(TaskStructureRecord task, int depth) {
      nodes.add(
        task.snapshot(
          name: names[task.taskId],
          depth: depth,
          wait: _waitOf(task, tasks),
        ),
      );
      for (final child in task.children) {
        final record = tasks[child];
        if (record != null) visit(record, depth + 1);
      }
    }

    final roots = tasks.values.toList()
      ..sort((left, right) => left.taskId.compareTo(right.taskId));
    for (final root in roots) {
      if (root.taskId == 0 || root.parentId == null) visit(root, 0);
    }
    return nodes;
  }

  TaskWaitState? _waitOf(
    TaskStructureRecord task,
    Map<int, TaskStructureRecord> tasks,
  ) {
    final cause = task.waitCause;
    final target = task.waitTarget;
    if (task.status != 'suspended' || cause == null || target == null) {
      return null;
    }
    if (cause != TaskWaitCause.join) {
      return TaskWaitState(cause: cause, target: target);
    }
    final scoped = [
      for (final child in task.children)
        if (tasks[child]?.scopeId == target) tasks[child]!,
    ];
    return TaskWaitState(
      cause: cause,
      target: target,
      pendingChildren:
          scoped.length - scoped.where((record) => record.isTerminal).length,
      totalChildren: scoped.length,
    );
  }
}
