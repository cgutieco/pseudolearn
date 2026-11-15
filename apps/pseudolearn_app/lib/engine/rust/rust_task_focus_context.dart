import '../../domain/model/analysis/source_range.dart';
import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/execution/execution_branch.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../../domain/model/execution/execution_task_context.dart';
import '../../domain/model/execution/watch_row.dart';
import 'rust_program_view.dart';
import 'rust_statement_stack.dart';
import 'rust_view_unit_index.dart';
import 'rust_wire_models.dart';

final class RustTaskFocusContext {
  final RustStatementStack stack = RustStatementStack();
  ExecutionTaskStatus status;
  int lastEventIndex;
  ExecutionFocus? focus;
  int focusRevision = 0;
  String? completionOutcome;
  String scopeName = 'global';
  int scopeDepth = 0;
  List<WatchRow> variables = const [];

  RustTaskFocusContext({required this.status, required this.lastEventIndex});

  factory RustTaskFocusContext.root() => RustTaskFocusContext(
    status: ExecutionTaskStatus.running,
    lastEventIndex: -1,
  )..scopeDepth = 1;

  factory RustTaskFocusContext.created(int eventIndex) => RustTaskFocusContext(
    status: ExecutionTaskStatus.created,
    lastEventIndex: eventIndex,
  );

  bool applyOrdinary({
    required RustEvent event,
    required int eventIndex,
    required RustProgramView view,
    required RustViewNode? Function(RustEvent) resolveNode,
    required RustViewUnitIndex units,
  }) {
    final valid = switch (event.eventClass) {
      'statement_entered' => _enterStatement(
        event: event,
        view: view,
        resolveNode: resolveNode,
        units: units,
      ),
      'statement_exited' => stack.exit(),
      'decision' => _focusOnDecision(event, resolveNode, units),
      'call' => _enterSubroutine(event, resolveNode, units),
      'return' => _exitSubroutine(),
      _ => true,
    };
    if (valid) lastEventIndex = eventIndex;
    return valid;
  }

  void recordEnvironment({
    required int eventIndex,
    required String scopeName,
    required int scopeDepth,
    required List<WatchRow> variables,
  }) {
    lastEventIndex = eventIndex;
    this.scopeName = scopeName;
    this.scopeDepth = scopeDepth;
    this.variables = List.unmodifiable(variables);
  }

  void finish({
    required int taskId,
    required RustTerminationKind termination,
    required String? failureReason,
    required bool failedTask,
  }) {
    final terminalStatus = switch (termination) {
      RustTerminationKind.completed when taskId == 0 =>
        ExecutionTaskStatus.completed,
      RustTerminationKind.failed when taskId == 0 => ExecutionTaskStatus.failed,
      RustTerminationKind.cancelled when taskId == 0 =>
        ExecutionTaskStatus.cancelledByHost,
      RustTerminationKind.limitReached when taskId == 0 =>
        ExecutionTaskStatus.limitReached,
      RustTerminationKind.failed when failedTask => ExecutionTaskStatus.failed,
      RustTerminationKind.failed => ExecutionTaskStatus.interruptedByFailure,
      RustTerminationKind.cancelled => ExecutionTaskStatus.interruptedByHost,
      RustTerminationKind.limitReached =>
        ExecutionTaskStatus.interruptedByLimit,
      _ => null,
    };
    if (terminalStatus == null || status.isTerminal) return;
    status = terminalStatus;
    completionOutcome = switch (termination) {
      RustTerminationKind.completed when taskId == 0 => 'success',
      RustTerminationKind.failed when taskId == 0 => failureReason ?? 'error',
      RustTerminationKind.cancelled when taskId == 0 => 'cancelled_by_host',
      RustTerminationKind.limitReached when taskId == 0 => 'limit_reached',
      _ => completionOutcome,
    };
  }

  ExecutionTaskContext snapshot(int taskId) => ExecutionTaskContext(
    taskId: taskId,
    status: status,
    completionOutcome: completionOutcome,
    lastEventIndex: lastEventIndex,
    focus: focus,
    focusRevision: focusRevision,
    blockPosition: stack.position,
    frames: stack.frames,
    scopeName: scopeName,
    scopeDepth: scopeDepth,
    variables: variables,
  );

  bool _enterStatement({
    required RustEvent event,
    required RustProgramView view,
    required RustViewNode? Function(RustEvent) resolveNode,
    required RustViewUnitIndex units,
  }) {
    final node = resolveNode(event);
    if (node == null) return false;
    stack.enter(node.id);
    if (rustNodeIsContainer(view, node)) return true;
    _focusOn(
      id: node.id,
      node: node,
      kind: ExecutionFocusKind.statement,
      units: units,
    );
    return true;
  }

  bool _focusOnDecision(
    RustEvent event,
    RustViewNode? Function(RustEvent) resolveNode,
    RustViewUnitIndex units,
  ) {
    final label = event.data['rama'];
    final rawIndex = event.data['indice'];
    if (label is! String || (rawIndex != null && rawIndex is! int)) {
      return false;
    }
    final node = resolveNode(event);
    if (node == null) return false;
    focus = ExecutionFocus(
      nodeId: node.id,
      range: _headerRange(node),
      kind: ExecutionFocusKind.decision,
      branch: _branchOf(label, rawIndex as int?),
      unitId: units.unitIdOf(node.id),
    );
    focusRevision++;
    return true;
  }

  bool _enterSubroutine(
    RustEvent event,
    RustViewNode? Function(RustEvent) resolveNode,
    RustViewUnitIndex units,
  ) {
    final node = resolveNode(event);
    final previous = focus;
    final focusNodeId = previous?.nodeId ?? node?.id;
    final focusRange = node?.range ?? previous?.range;
    final focusUnitId =
        previous?.unitId ?? (node == null ? null : units.unitIdOf(node.id));
    if (focusNodeId == null || focusRange == null) return false;
    stack.enterFrame();
    focus = ExecutionFocus(
      nodeId: focusNodeId,
      range: focusRange,
      kind: ExecutionFocusKind.subroutineEntered,
      unitId: focusUnitId,
    );
    focusRevision++;
    return true;
  }

  bool _exitSubroutine() {
    if (!stack.exitFrame()) return false;
    final previous = focus;
    if (previous == null) return true;
    focus = ExecutionFocus(
      nodeId: previous.nodeId,
      range: previous.range,
      kind: ExecutionFocusKind.subroutineExited,
      unitId: previous.unitId,
    );
    focusRevision++;
    return true;
  }

  void _focusOn({
    required ProgramNodeId id,
    required RustViewNode node,
    required ExecutionFocusKind kind,
    required RustViewUnitIndex units,
  }) {
    focus = ExecutionFocus(
      nodeId: id,
      range: node.range,
      kind: kind,
      unitId: units.unitIdOf(id),
    );
    focusRevision++;
  }
}

ExecutionBranch? _branchOf(String label, int? caseIndex) => switch (label) {
  'afirmativa' => const ExecutionBranch(kind: ExecutionBranchKind.affirmative),
  'negativa' => const ExecutionBranch(kind: ExecutionBranchKind.negative),
  'caso' => ExecutionBranch(
    kind: ExecutionBranchKind.selectedCase,
    caseIndex: caseIndex,
  ),
  'otro' => const ExecutionBranch(kind: ExecutionBranchKind.defaultCase),
  _ => null,
};

SourceRange _headerRange(RustViewNode node) {
  final range = node.range;
  final header = node.text.split('\n').first.split('\r').first;
  final lineLength = header.length;
  return SourceRange(
    startOffset: range.startOffset,
    endOffset: range.startOffset + lineLength,
    startLine: range.startLine,
    endLine: range.startLine,
    startColumn: range.startColumn,
    endColumn: range.startColumn + header.runes.length,
  );
}
