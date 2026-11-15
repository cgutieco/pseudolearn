import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/execution/block_position.dart';
import '../../domain/model/execution/execution_stack_frame.dart';

final class RustStatementStack {
  final List<ProgramNodeId> _entered = [];
  final List<int> _frameMarks = [];

  BlockPosition get position => BlockPosition(
    depth: _entered.length,
    enclosingNodeId: _entered.length >= 2
        ? _entered[_entered.length - 2]
        : null,
  );

  List<ExecutionStackFrame> get frames {
    if (_entered.isEmpty && _frameMarks.isEmpty) return const [];
    final boundaries = [0, ..._frameMarks, _entered.length];
    return [
      for (var index = 0; index < boundaries.length - 1; index++)
        ExecutionStackFrame(
          statementNodes: _entered.sublist(
            boundaries[index],
            boundaries[index + 1],
          ),
        ),
    ];
  }

  void enter(ProgramNodeId nodeId) => _entered.add(nodeId);

  bool exit() {
    if (_entered.isEmpty) return false;
    _entered.removeLast();
    return true;
  }

  void enterFrame() => _frameMarks.add(_entered.length);

  bool exitFrame() {
    if (_frameMarks.isEmpty) return false;
    final mark = _frameMarks.removeLast();
    while (_entered.length > mark) {
      _entered.removeLast();
    }
    return true;
  }
}
