import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/analysis/program_view_control_exit.dart';
import 'rust_program_view.dart';

final class RustControlExits {
  final RustProgramView _view;
  final Map<int, ProgramViewControlExit> _exits;
  final Map<int, ProgramViewCleanupScope> _scopes;
  final Set<int> _breakTargets;

  RustControlExits(RustProgramView view)
    : _view = view,
      _exits = {
        for (final exit in view.staticData.exits) exit.exitNodeId.value: exit,
      },
      _scopes = {
        for (final scope in view.staticData.cleanupScopes)
          scope.bodyNodeId.value: scope,
      },
      _breakTargets = {
        for (final exit in view.staticData.exits)
          if (exit.kind == ProgramViewExitKind.breakLoop)
            ?exit.targetNodeId?.value,
      };

  List<int> exitCleanupLines(RustViewNode exitNode) =>
      _linesOf(_exits[exitNode.id.value]?.cleanupNodeIds ?? const []);

  List<int> normalCleanupLines(RustViewNode body) =>
      _linesOf(_scopes[body.id.value]?.cleanupNodeIds ?? const []);

  int? breakTargetLine(RustViewNode exitNode) {
    final target = _exits[exitNode.id.value]?.targetNodeId;
    return target == null ? null : _view.nodeById(target)?.range.startLine;
  }

  bool isBreakTarget(RustViewNode loop) =>
      _breakTargets.contains(loop.id.value);

  List<int> _linesOf(List<ProgramNodeId> nodeIds) => [
    for (final nodeId in nodeIds)
      if (_view.nodeById(nodeId) case final RustViewNode node)
        node.range.startLine,
  ];
}
