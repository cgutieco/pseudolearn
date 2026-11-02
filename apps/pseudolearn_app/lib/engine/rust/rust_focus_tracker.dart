import '../../domain/model/execution/block_position.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/watch_row.dart';
import 'rust_event_classes.dart';
import 'rust_program_view.dart';
import 'rust_task_focus_context.dart';
import 'rust_view_unit_index.dart';
import 'rust_wire_models.dart';

final class RustFocusTracker {
  final RustProgramView _view;
  final RustViewUnitIndex _units;
  final Map<int, RustViewNode> _focusNodes;
  final Map<int, RustTaskFocusContext> _contexts = {
    0: RustTaskFocusContext.root(),
  };

  int _currentTaskId = 0;
  int? _failedTaskId;
  int _focusRevision = 0;

  RustFocusTracker(this._view)
    : _units = RustViewUnitIndex.of(_view),
      _focusNodes = _indexFocusNodes(_view);

  int get currentTaskId => _currentTaskId;

  ExecutionTaskContext get activeContext =>
      _contexts[_currentTaskId]!.snapshot(_currentTaskId);

  List<ExecutionTaskContext> get taskContexts {
    final identifiers = _contexts.keys.toList()..sort();
    return List.unmodifiable([
      for (final identifier in identifiers)
        _contexts[identifier]!.snapshot(identifier),
    ]);
  }

  ExecutionFocus? get focus => _contexts[_currentTaskId]!.focus;

  String get scopeName => _contexts[_currentTaskId]!.scopeName;

  int get scopeDepth => _contexts[_currentTaskId]!.scopeDepth;

  List<WatchRow> get variables => _contexts[_currentTaskId]!.variables;

  int get focusRevision => _focusRevision;

  BlockPosition get blockPosition => _contexts[_currentTaskId]!.stack.position;

  bool apply(RustEvent event, int eventIndex) {
    if (event.sourceRevisionId != null &&
        event.sourceRevisionId != _view.revision) {
      return false;
    }
    final taskEvent = RustTaskEvent.tryFrom(event);
    if (taskEvent != null) return _applyTaskEvent(taskEvent, eventIndex);
    final context = _contexts[_currentTaskId]!;
    final previousRevision = context.focusRevision;
    if (!context.applyOrdinary(
      event: event,
      eventIndex: eventIndex,
      view: _view,
      resolveNode: _resolveNode,
      units: _units,
    )) {
      return false;
    }
    if (context.focusRevision != previousRevision) _focusRevision++;
    if (event.eventClass == 'failure') _failedTaskId = _currentTaskId;
    return true;
  }

  bool recordEnvironment({
    required int taskId,
    required int eventIndex,
    required String scopeName,
    required int scopeDepth,
    required List<WatchRow> variables,
  }) {
    final context = _contexts[taskId];
    if (context == null) return false;
    context.recordEnvironment(
      eventIndex: eventIndex,
      scopeName: scopeName,
      scopeDepth: scopeDepth,
      variables: variables,
    );
    return true;
  }

  void finishRoot(RustTerminationKind termination, String? failureReason) {
    for (final entry in _contexts.entries) {
      entry.value.finish(
        taskId: entry.key,
        termination: termination,
        failureReason: failureReason,
        failedTask: entry.key == _failedTaskId,
      );
    }
  }

  bool _applyTaskEvent(RustTaskEvent event, int eventIndex) =>
      switch (event.eventClass) {
        'task_spawned' => _spawnTask(event, eventIndex),
        'task_ready' => _readyTask(event, eventIndex),
        'task_resumed' => _resumeTask(event, eventIndex),
        'task_suspended' => _suspendTask(event, eventIndex),
        'task_completed' => _completeTask(event, eventIndex),
        'task_cancel_requested' => _requestTaskCancellation(event, eventIndex),
        'scope_joined' => _recordJoin(event, eventIndex),
        'effect_delivered' => _recordDelivery(event, eventIndex),
        _ => _recordCurrentEvent(eventIndex),
      };

  bool _spawnTask(RustTaskEvent event, int eventIndex) {
    final taskId = event.task;
    final parent = event.intOf('parent');
    if (taskId == null ||
        taskId == 0 ||
        parent != _currentTaskId ||
        _contexts.containsKey(taskId)) {
      return false;
    }
    _contexts[taskId] = RustTaskFocusContext.created(eventIndex);
    _contexts[parent]!.lastEventIndex = eventIndex;
    return true;
  }

  bool _readyTask(RustTaskEvent event, int eventIndex) {
    final context = _contextFor(event.task);
    if (context == null ||
        (context.status != ExecutionTaskStatus.created &&
            context.status != ExecutionTaskStatus.suspended)) {
      return false;
    }
    context.status = ExecutionTaskStatus.ready;
    context.lastEventIndex = eventIndex;
    return true;
  }

  bool _resumeTask(RustTaskEvent event, int eventIndex) {
    final taskId = event.task;
    final context = _contextFor(taskId);
    if (context == null ||
        (context.status != ExecutionTaskStatus.ready &&
            context.status != ExecutionTaskStatus.suspended &&
            context.status != ExecutionTaskStatus.cancellationRequested)) {
      return false;
    }
    if (_currentTaskId != taskId) _focusRevision++;
    _currentTaskId = taskId!;
    context.status = ExecutionTaskStatus.running;
    context.lastEventIndex = eventIndex;
    return true;
  }

  bool _suspendTask(RustTaskEvent event, int eventIndex) {
    final context = _contextFor(event.task);
    if (context == null ||
        event.task != _currentTaskId ||
        context.status != ExecutionTaskStatus.running) {
      return false;
    }
    context.status = ExecutionTaskStatus.suspended;
    context.lastEventIndex = eventIndex;
    return true;
  }

  bool _completeTask(RustTaskEvent event, int eventIndex) {
    final context = _contextFor(event.task);
    final outcome = event.textOf('outcome');
    if (context == null ||
        !{'success', 'error', 'cancelled'}.contains(outcome) ||
        (context.status == ExecutionTaskStatus.cancellationRequested
            ? false
            : event.task != _currentTaskId ||
                  context.status != ExecutionTaskStatus.running)) {
      return false;
    }
    context.status = outcome == 'cancelled'
        ? ExecutionTaskStatus.cancelled
        : ExecutionTaskStatus.completed;
    context.completionOutcome = outcome;
    context.lastEventIndex = eventIndex;
    return true;
  }

  bool _requestTaskCancellation(RustTaskEvent event, int eventIndex) {
    final context = _contextFor(event.task);
    if (context == null ||
        event.intOf('origin') != _currentTaskId ||
        context.status.isTerminal ||
        context.status == ExecutionTaskStatus.running) {
      return false;
    }
    context.status = ExecutionTaskStatus.cancellationRequested;
    context.lastEventIndex = eventIndex;
    return true;
  }

  bool _recordJoin(RustTaskEvent event, int eventIndex) {
    if (event.task != _currentTaskId) return false;
    return _recordCurrentEvent(eventIndex);
  }

  bool _recordDelivery(RustTaskEvent event, int eventIndex) {
    final context = _contextFor(event.task);
    if (context == null) return false;
    context.lastEventIndex = eventIndex;
    return true;
  }

  bool _recordCurrentEvent(int eventIndex) {
    _contexts[_currentTaskId]!.lastEventIndex = eventIndex;
    return true;
  }

  RustTaskFocusContext? _contextFor(int? taskId) =>
      taskId == null ? null : _contexts[taskId];

  RustViewNode? _resolveNode(RustEvent event) {
    final source = _view.node(event.nodeId);
    return source == null ? null : _focusNodes[source.id.value] ?? source;
  }
}

Map<int, RustViewNode> _indexFocusNodes(RustProgramView view) => {
  for (final node in view.nodes.where((node) => node.syntaxKind == 'statement'))
    for (final child in node.children)
      if (node.childRoles[child] == 'statement') child: node,
};
