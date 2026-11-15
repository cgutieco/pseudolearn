import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/task_event_kind.dart';
import '../../domain/model/execution/task_structure_scene.dart';

final class TaskStructureRecord {
  final int taskId;
  final int? parentId;
  final int? scopeId;
  final int? createdAtEvent;
  int? completedAtEvent;
  int? currentLine;
  String status;
  String? outcome;
  TaskWaitCause? waitCause;
  int? waitTarget;
  final List<int> children = [];
  final List<TaskJoinMarker> joins = [];

  TaskStructureRecord({
    required this.taskId,
    required this.parentId,
    required this.scopeId,
    required this.createdAtEvent,
  }) : status = 'created';

  factory TaskStructureRecord.root() => TaskStructureRecord(
    taskId: 0,
    parentId: null,
    scopeId: null,
    createdAtEvent: null,
  )..status = 'running';

  bool get isTerminal =>
      ExecutionTaskStatus.values.asNameMap()[status]?.isTerminal ?? false;

  void changeStatus(String next) {
    status = next;
    waitCause = null;
    waitTarget = null;
  }

  void suspend(TaskWaitCause cause, int? target) {
    status = 'suspended';
    waitCause = cause;
    waitTarget = target;
  }

  void complete(int event, String? result) {
    completedAtEvent = event;
    changeStatus(result == 'cancelled' ? 'cancelled' : 'completed');
    outcome = result;
  }

  void observe(ExecutionTaskStatus nextStatus, String? result) {
    if (nextStatus.name != status) changeStatus(nextStatus.name);
    outcome = result;
  }

  TaskStructureNode snapshot({
    required String? name,
    required int depth,
    required TaskWaitState? wait,
  }) => TaskStructureNode(
    taskId: taskId,
    name: name,
    depth: depth,
    parentId: parentId,
    scopeId: scopeId,
    createdAtEvent: createdAtEvent,
    completedAtEvent: completedAtEvent,
    currentLine: currentLine,
    status: status,
    outcome: outcome,
    wait: wait,
    children: children,
    joins: joins,
  );
}
