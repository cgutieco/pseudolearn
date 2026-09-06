import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/program_node_id.dart';

final class UnitMembershipIndex {
  final Map<NodeId, String> _nodeToUnit;

  const UnitMembershipIndex._(this._nodeToUnit);

  const UnitMembershipIndex.empty() : _nodeToUnit = const {};

  factory UnitMembershipIndex.of(SourceUnitNode unit) {
    final map = <NodeId, String>{};

    if (unit.algorithm != null) {
      final algo = unit.algorithm!;
      _indexSubtree(algo, 'alg_${algo.name}', map);
    }

    for (final sub in unit.subroutines) {
      _indexSubtree(sub, 'sub_${sub.name}', map);
    }

    for (final cls in unit.classes) {
      _indexClass(cls, map);
    }

    return UnitMembershipIndex._(map);
  }

  static void _indexClass(ClassNode cls, Map<NodeId, String> map) {
    for (final member in cls.members) {
      if (member is ConstructorDeclarationNode) {
        _indexSubtree(member, 'ctor_${cls.name}', map);
      } else if (member is MethodDeclarationNode) {
        _indexSubtree(member, 'method_${cls.name}_${member.name}', map);
      }
    }
  }

  static void _indexSubtree(
    AstNode root,
    String unitId,
    Map<NodeId, String> map,
  ) {
    final pending = <AstNode>[root];
    while (pending.isNotEmpty) {
      final node = pending.removeLast();
      map[node.id] = unitId;
      pending.addAll(getChildNodes(node));
    }
  }

  String? unitIdOf(NodeId id) => _nodeToUnit[id];

  String? unitIdOfProgramNodeId(ProgramNodeId id) =>
      _nodeToUnit[NodeId(id.value)];
}
