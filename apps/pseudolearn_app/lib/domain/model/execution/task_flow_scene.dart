import 'execution_history_event.dart';
import 'task_event_kind.dart';

final class TaskFlowColumn {
  final int taskId;
  final String? name;
  final int order;

  const TaskFlowColumn({
    required this.taskId,
    required this.name,
    required this.order,
  });
}

enum TaskFlowLinkKind { creation, wait }

final class TaskFlowRow {
  final ExecutionHistoryEvent event;
  final TaskEventKind kind;
  final int taskId;
  final int column;
  final TaskFlowLinkKind? linkKind;
  final List<int> linkedColumns;
  final int? relatedTaskId;
  final TaskWaitCause? waitCause;
  final int? channelId;
  final String? detail;

  TaskFlowRow({
    required this.event,
    required this.kind,
    required this.taskId,
    required this.column,
    this.linkKind,
    List<int> linkedColumns = const [],
    this.relatedTaskId,
    this.waitCause,
    this.channelId,
    this.detail,
  }) : linkedColumns = List.unmodifiable(linkedColumns);
}

final class TaskFlowScene {
  final List<TaskFlowColumn> columns;
  final List<TaskFlowRow> rows;
  final Map<int, String> taskNames;
  final int rangeStart;
  final int rangeEnd;

  TaskFlowScene({
    required List<TaskFlowColumn> columns,
    required List<TaskFlowRow> rows,
    required Map<int, String> taskNames,
    required this.rangeStart,
    required this.rangeEnd,
  }) : columns = List.unmodifiable(columns),
       rows = List.unmodifiable(rows),
       taskNames = Map.unmodifiable(taskNames);

  int? rowIndexOf(int eventIndex) {
    for (var index = 0; index < rows.length; index++) {
      if (rows[index].event.index == eventIndex) return index;
    }
    return null;
  }

  TaskFlowRow? rowOf(int eventIndex) {
    final index = rowIndexOf(eventIndex);
    return index == null ? null : rows[index];
  }

  String? nameOf(int taskId) => taskNames[taskId];
}
