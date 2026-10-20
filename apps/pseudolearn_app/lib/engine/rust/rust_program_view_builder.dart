part of 'rust_program_view.dart';

final class _RustViewNodeBuilder {
  final Map<String, int> _ordinals;
  final SourceOffsetIndex _offsets;

  const _RustViewNodeBuilder(this._ordinals, this._offsets);

  ({Map<String, RustViewNode> byIdentifier, Map<int, String> identifiers})
  build(List<Map<String, Object?>> nodes) {
    final byIdentifier = <String, RustViewNode>{};
    final identifiers = <int, String>{};
    for (final node in nodes) {
      final identifier = node['node_id'] as String;
      final ordinal = _ordinals[identifier]!;
      identifiers[ordinal] = identifier;
      byIdentifier[identifier] = _buildNode(node, ordinal);
    }
    return (byIdentifier: byIdentifier, identifiers: identifiers);
  }

  RustViewNode _buildNode(Map<String, Object?> node, int ordinal) {
    final span = node['span'] as Map<String, Object?>;
    return RustViewNode(
      id: ProgramNodeId(ordinal),
      kind: node['kind'] as String,
      syntaxKind: node['syntax_kind'] as String,
      text: RustProgramView._textOf(span, _offsets),
      range: RustProgramView._rangeOf(span, _offsets),
      dimensions: node['dimensions'] as int?,
      semantics: RustViewSemantics.fromJson(node),
      children: [
        for (final child in node['child_node_ids'] as List<Object?>)
          _ordinals[child as String]!,
      ],
      childRoles: {
        for (final role
            in (node['child_roles'] as List<Object?>? ?? const [])
                .cast<Map<String, Object?>>())
          _ordinals[role['node_id'] as String]!: role['role'] as String,
      },
    );
  }
}

Map<String, int> _ordinalsFor(List<Map<String, Object?>> nodes) => {
  for (var index = 0; index < nodes.length; index++)
    nodes[index]['node_id'] as String: index,
};

List<RustViewUnit> _unitsFor(
  Map<String, Object?> json,
  Map<String, int> ordinals,
  SourceOffsetIndex offsets,
) => [
  for (final unit
      in (json['units'] as List<Object?>).cast<Map<String, Object?>>())
    RustViewUnit(
      id: unit['node_id'] as String,
      kind: unit['kind'] as String,
      name: unit['name'] as String,
      order: unit['order'] as int,
      nodeId: ProgramNodeId(ordinals[unit['node_id'] as String]!),
      range: RustProgramView._rangeOf(
        unit['span'] as Map<String, Object?>,
        offsets,
      ),
    ),
];

List<RustViewMember> _membersFor(
  Map<String, Object?> json,
  Map<String, int> ordinals,
) => [
  for (final member
      in (json['members'] as List<Object?>).cast<Map<String, Object?>>())
    RustViewMember(
      className: member['class'] as String,
      name: member['name'] as String,
      kind: member['kind'] as String,
      visibility: member['visibility'] as String,
      arity: member['arity'] as int?,
      typeName: member['type'] as String?,
      dimensions: member['dimensions'] as int? ?? 0,
      nodeId: member['node_id'] is String
          ? ProgramNodeId(ordinals[member['node_id'] as String]!)
          : null,
    ),
];

Map<String, String> _superclassesFor(Map<String, Object?> json) => {
  for (final relation
      in (json['inheritance'] as List<Object?>).cast<Map<String, Object?>>())
    relation['class'] as String: relation['base'] as String,
};

List<RustViewNode> rustChildrenOf(RustProgramView view, RustViewNode node) => [
  for (final child in node.children)
    if (view.nodeById(ProgramNodeId(child)) case final RustViewNode value)
      value,
];

List<RustViewNode> rustChildrenForRole(
  RustProgramView view,
  RustViewNode node,
  String role,
) => [
  for (final child in rustChildrenOf(view, node))
    if (node.childRoles[child.id.value] == role) child,
];

List<RustViewNode> rustStatementsOf(RustProgramView view, RustViewNode body) =>
    rustChildrenForRole(view, body, 'statement');

bool rustNodeIsContainer(RustProgramView view, RustViewNode node) {
  const compoundKinds = {
    'conditional',
    'switch',
    'while_loop',
    'repeat_loop',
    'for_loop',
  };
  return compoundKinds.contains(node.syntaxKind) ||
      rustChildrenOf(
        view,
        node,
      ).any((child) => compoundKinds.contains(child.syntaxKind));
}
