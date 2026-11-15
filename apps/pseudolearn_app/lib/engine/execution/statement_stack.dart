import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/execution/block_position.dart';

final class StatementStack {
  final List<ProgramNodeId> _entered = [];
  final List<int> _frameMarks = [];

  BlockPosition get position => BlockPosition(
        depth: _entered.length,
        enclosingNodeId:
            _entered.length >= 2 ? _entered[_entered.length - 2] : null,
      );

  void enter(ProgramNodeId nodeId) => _entered.add(nodeId);

  void exit() {
    if (_entered.isEmpty) return;
    _entered.removeLast();
  }

  void enterFrame() => _frameMarks.add(_entered.length);

  void exitFrame() {
    if (_frameMarks.isEmpty) return;
    final mark = _frameMarks.removeLast();
    while (_entered.length > mark) {
      _entered.removeLast();
    }
  }
}
