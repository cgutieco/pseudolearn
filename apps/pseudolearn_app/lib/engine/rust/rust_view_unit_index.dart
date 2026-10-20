import '../../domain/model/analysis/program_node_id.dart';
import 'rust_diagram_unit_identifier.dart';
import 'rust_program_view.dart';

final class RustViewUnitIndex {
  final Map<int, String> _unitByNode;

  RustViewUnitIndex._(this._unitByNode);

  factory RustViewUnitIndex.of(RustProgramView view) {
    final unitByNode = <int, String>{};
    for (final unit in view.units) {
      if (unit.kind == 'class') continue;
      _indexSubtree(
        view: view,
        rootId: unit.nodeId,
        unitId: RustDiagramUnitIdentifier.fromUnit(unit),
        unitByNode: unitByNode,
      );
    }
    for (final member in view.members) {
      final nodeId = member.nodeId;
      if (nodeId == null || member.kind == 'field') continue;
      _indexSubtree(
        view: view,
        rootId: nodeId,
        unitId: RustDiagramUnitIdentifier.fromMember(member),
        unitByNode: unitByNode,
      );
    }
    return RustViewUnitIndex._(unitByNode);
  }

  String? unitIdOf(ProgramNodeId nodeId) => _unitByNode[nodeId.value];
}

void _indexSubtree({
  required RustProgramView view,
  required ProgramNodeId rootId,
  required String unitId,
  required Map<int, String> unitByNode,
}) {
  final pending = <ProgramNodeId>[rootId];
  final visited = <int>{};
  while (pending.isNotEmpty) {
    final nodeId = pending.removeLast();
    if (!visited.add(nodeId.value)) continue;
    final node = view.nodeById(nodeId);
    if (node == null) continue;
    unitByNode[nodeId.value] = unitId;
    pending.addAll(node.children.map(ProgramNodeId.new));
  }
}
