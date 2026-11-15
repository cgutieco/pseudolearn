import '../../domain/model/execution/execution_history_event.dart';
import '../../domain/model/execution/task_event_kind.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../../domain/ports/task_flow_projector.dart';
import 'task_event_classifier.dart';
import 'task_spawn_registry.dart';

final class TaskFlowProjection implements TaskFlowProjector {
  const TaskFlowProjection();

  @override
  TaskFlowScene project({
    required List<ExecutionHistoryEvent> events,
    required int rangeStart,
    required int rangeEnd,
  }) {
    final ordered = TaskEventClassifier.ordered(events);
    final names = TaskEventClassifier.taskNames(ordered);
    final spawns = TaskSpawnRegistry.from(ordered);
    final columns = _columns(ordered, names);
    final order = {for (final column in columns) column.taskId: column.order};
    return TaskFlowScene(
      columns: columns,
      rows: [
        for (final event in ordered)
          if (event.index >= rangeStart && event.index <= rangeEnd)
            _row(event, order, spawns),
      ],
      taskNames: names,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  List<TaskFlowColumn> _columns(
    List<ExecutionHistoryEvent> ordered,
    Map<int, String> names,
  ) {
    final taskIds = <int>{0};
    for (final event in ordered) {
      taskIds.add(event.taskId);
      final subject = TaskEventClassifier.integer(event.data['task']);
      if (subject != null && event.eventClass.startsWith('task_')) {
        taskIds.add(subject);
      }
    }
    final sorted = taskIds.toList()..sort();
    return [
      for (var order = 0; order < sorted.length; order++)
        TaskFlowColumn(
          taskId: sorted[order],
          name: names[sorted[order]],
          order: order,
        ),
    ];
  }

  TaskFlowRow _row(
    ExecutionHistoryEvent event,
    Map<int, int> order,
    TaskSpawnRegistry spawns,
  ) {
    final kind = TaskEventClassifier.kindOf(event);
    final subject = _subjectOf(event, kind);
    final column = order[subject] ?? 0;
    return switch (kind) {
      TaskEventKind.spawn => _spawnRow(
        event,
        subject: subject,
        column: column,
        order: order,
      ),
      TaskEventKind.suspend => _waitRow(
        event,
        subject: subject,
        column: column,
        order: order,
        spawns: spawns,
      ),
      _ => TaskFlowRow(
        event: event,
        kind: kind,
        taskId: subject,
        column: column,
        channelId: TaskEventClassifier.integer(event.data['channel']),
        detail: _detailOf(event),
      ),
    };
  }

  TaskFlowRow _spawnRow(
    ExecutionHistoryEvent event, {
    required int subject,
    required int column,
    required Map<int, int> order,
  }) {
    final child = TaskEventClassifier.integer(event.data['task']);
    final childColumn = child == null ? null : order[child];
    return TaskFlowRow(
      event: event,
      kind: TaskEventKind.spawn,
      taskId: subject,
      column: column,
      linkKind: childColumn == null ? null : TaskFlowLinkKind.creation,
      linkedColumns: [?childColumn],
      relatedTaskId: child,
    );
  }

  TaskFlowRow _waitRow(
    ExecutionHistoryEvent event, {
    required int subject,
    required int column,
    required Map<int, int> order,
    required TaskSpawnRegistry spawns,
  }) {
    final cause = TaskEventClassifier.waitCauseOf(event);
    final target = TaskEventClassifier.integer(event.data['target']);
    final targets = switch (cause) {
      TaskWaitCause.task => [?target],
      TaskWaitCause.join when target != null => spawns.childrenOf(
        parent: subject,
        scope: target,
        before: event.index,
      ),
      _ => const <int>[],
    };
    final linked = [
      for (final task in targets)
        if (order[task] != null) order[task]!,
    ];
    return TaskFlowRow(
      event: event,
      kind: TaskEventKind.suspend,
      taskId: subject,
      column: column,
      linkKind: linked.isEmpty ? null : TaskFlowLinkKind.wait,
      linkedColumns: linked,
      relatedTaskId: cause == TaskWaitCause.task ? target : null,
      waitCause: cause,
      channelId: _isChannelWait(cause) ? target : null,
    );
  }

  int _subjectOf(ExecutionHistoryEvent event, TaskEventKind kind) =>
      switch (kind) {
        TaskEventKind.ready ||
        TaskEventKind.resume ||
        TaskEventKind.suspend ||
        TaskEventKind.complete ||
        TaskEventKind.cancelRequest ||
        TaskEventKind.join ||
        TaskEventKind.effectDelivered =>
          TaskEventClassifier.integer(event.data['task']) ?? event.taskId,
        _ => event.taskId,
      };

  String? _detailOf(ExecutionHistoryEvent event) {
    final text =
        event.data['nombre'] ?? event.data['texto'] ?? event.data['outcome'];
    return text is String ? text.trimRight() : null;
  }

  bool _isChannelWait(TaskWaitCause cause) => switch (cause) {
    TaskWaitCause.channelSend ||
    TaskWaitCause.channelReceive ||
    TaskWaitCause.select => true,
    _ => false,
  };
}
