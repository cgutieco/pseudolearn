import '../../domain/model/diagram/class_model.dart';
import 'rust_member_signature.dart';
import 'rust_program_view.dart';
import 'rust_value_type_projection.dart';

final class RustGenericSubprogramBoxes {
  final RustProgramView _view;

  const RustGenericSubprogramBoxes(this._view);

  Map<int, ClassBox> boxes(Map<int, int> constraintOwners) => {
    for (final unit in _view.units)
      if (unit.kind == 'subprogram' &&
          (constraintOwners.values.contains(unit.nodeId.value) ||
              RustValueTypeProjection.isGeneric(_view, unit.nodeId)))
        unit.nodeId.value: _box(unit),
  };

  Map<int, int> constraintOwners() {
    final wanted = {
      for (final constraint in _view.staticData.constraints)
        constraint.parameterNodeId.value,
    };
    final owners = <int, int>{};
    for (final unit in _view.units) {
      final root = _view.nodeById(unit.nodeId);
      if (unit.kind != 'subprogram' || root == null) continue;
      _collect(root, (owner: unit.nodeId.value, wanted: wanted), owners);
    }
    return owners;
  }

  ClassBox _box(RustViewUnit unit) {
    final node = _view.nodeById(unit.nodeId);
    final line = node?.range.startLine ?? unit.range.startLine;
    return ClassBox(
      name: unit.name,
      attributes: const [],
      methods: [
        ClassMemberRow(
          text: RustMemberSignature(_view).of(unit.name, node),
          visibility: ClassMemberVisibility.public,
          nodeId: unit.nodeId,
          sourceLine: line,
        ),
      ],
      nodeId: unit.nodeId,
      sourceLine: line,
      kind: ClassBoxKind.genericSubprogram,
    );
  }

  void _collect(
    RustViewNode node,
    ({int owner, Set<int> wanted}) search,
    Map<int, int> into,
  ) {
    if (search.wanted.contains(node.id.value)) {
      into[node.id.value] = search.owner;
    }
    for (final child in rustChildrenOf(_view, node)) {
      _collect(child, search, into);
    }
  }
}
