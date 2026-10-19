import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/execution/block_position.dart';
import '../../domain/model/execution/execution_branch.dart';
import '../../domain/model/execution/execution_focus.dart';
import 'rust_program_view.dart';
import 'rust_statement_stack.dart';
import 'rust_wire_models.dart';

final class RustFocusTracker {
  final RustProgramView _view;
  final RustStatementStack _stack = RustStatementStack();

  ExecutionFocus? focus;
  int focusRevision = 0;

  RustFocusTracker(this._view);

  BlockPosition get blockPosition => _stack.position;

  void apply(RustEvent event) {
    switch (event.eventClass) {
      case 'statement_entered':
        _enterStatement(event);
      case 'statement_exited':
        _stack.exit();
      case 'decision':
        _focusOnDecision(event);
      case 'call':
        _enterSubroutine(event);
      case 'return':
        _markBoundary(ExecutionFocusKind.subroutineExited);
        _stack.exitFrame();
    }
  }

  void _enterStatement(RustEvent event) {
    final node = _view.node(event.nodeId);
    if (node == null) return;
    _stack.enter(node.id);
    if (rustNodeIsContainer(_view, node)) return;
    _focusOn(node.id, node, ExecutionFocusKind.statement);
  }

  void _focusOnDecision(RustEvent event) {
    final node = _view.node(event.nodeId);
    if (node == null) return;
    focus = ExecutionFocus(
      nodeId: node.id,
      range: node.range,
      kind: ExecutionFocusKind.decision,
      branch: _branchOf(event.data),
    );
    focusRevision++;
  }

  void _enterSubroutine(RustEvent event) {
    _stack.enterFrame();
    final node = _view.node(event.nodeId);
    final previous = focus;
    focus = ExecutionFocus(
      nodeId: previous?.nodeId ?? const ProgramNodeId(0),
      range: node?.range ?? previous!.range,
      kind: ExecutionFocusKind.subroutineEntered,
    );
    focusRevision++;
  }

  void _markBoundary(ExecutionFocusKind kind) {
    final previous = focus;
    if (previous != null) {
      focus = ExecutionFocus(
        nodeId: previous.nodeId,
        range: previous.range,
        kind: kind,
      );
    }
    focusRevision++;
  }

  void _focusOn(ProgramNodeId id, RustViewNode node, ExecutionFocusKind kind) {
    focus = ExecutionFocus(nodeId: id, range: node.range, kind: kind);
    focusRevision++;
  }

  ExecutionBranch? _branchOf(Map<String, Object?> data) {
    final index = data['indice'] as int?;
    return switch (data['rama']) {
      'afirmativa' => const ExecutionBranch(
        kind: ExecutionBranchKind.affirmative,
      ),
      'negativa' => const ExecutionBranch(kind: ExecutionBranchKind.negative),
      'caso' => ExecutionBranch(
        kind: ExecutionBranchKind.selectedCase,
        caseIndex: index,
      ),
      'otro' => const ExecutionBranch(kind: ExecutionBranchKind.defaultCase),
      _ => null,
    };
  }
}
