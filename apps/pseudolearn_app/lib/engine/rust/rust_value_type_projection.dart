import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/class_model.dart';
import 'rust_program_view.dart';
import 'rust_type_parameter_text.dart';

final class RustValueTypeProjection {
  final RustProgramView _view;

  const RustValueTypeProjection(this._view);

  static bool isGeneric(RustProgramView view, ProgramNodeId unit) {
    final node = view.nodeById(unit);
    if (node == null) return false;
    return rustChildrenOf(
      view,
      node,
    ).any((child) => child.syntaxKind == 'type_parameters');
  }

  List<ClassBox> boxes() => [
    for (final node in _view.nodes)
      if (node.syntaxKind == 'enum_unit')
        _box(node, ClassBoxKind.enumeration, _members(node))
      else if (node.syntaxKind == 'record_unit')
        _box(node, ClassBoxKind.record, _fields(node))
      else if (node.syntaxKind == 'variant_unit')
        _box(node, ClassBoxKind.variant, _alternatives(node)),
  ];

  ClassBox _box(
    RustViewNode node,
    ClassBoxKind kind,
    List<ClassMemberRow> rows,
  ) => ClassBox(
    name: _view.childForRole(node, 'name')?.text ?? node.text.trim(),
    attributes: rows,
    methods: const [],
    nodeId: node.id,
    sourceLine: node.range.startLine,
    kind: kind,
    typeParameters: RustTypeParameterText(_view).of(node),
  );

  List<ClassMemberRow> _members(RustViewNode node) => [
    for (final members in rustChildrenForRole(_view, node, 'members'))
      for (final member in rustChildrenForRole(_view, members, 'member'))
        _row(member, member.text, ClassRowRole.enumMember),
  ];

  List<ClassMemberRow> _alternatives(RustViewNode node) => [
    for (final alternative in rustChildrenForRole(_view, node, 'alternative'))
      _row(alternative, _alternativeText(alternative), ClassRowRole.enumMember),
  ];

  String _alternativeText(RustViewNode alternative) {
    final name = _view.childForRole(alternative, 'name')?.text.trim() ?? '';
    final fields = [
      for (final field in rustChildrenForRole(_view, alternative, 'field'))
        '${_view.childForRole(field, 'name')?.text.trim() ?? ''}: '
            '${_view.childForRole(field, 'type')?.text.trim() ?? ''}',
    ];
    return fields.isEmpty ? name : '$name(${fields.join(', ')})';
  }

  List<ClassMemberRow> _fields(RustViewNode node) => [
    for (final field in rustChildrenForRole(_view, node, 'field'))
      for (final declaration in rustChildrenOf(_view, field))
        ..._declaredFields(declaration),
  ];

  List<ClassMemberRow> _declaredFields(RustViewNode declaration) {
    final type = _view.childForRole(declaration, 'type')?.text ?? '';
    return [
      for (final binding in rustChildrenForRole(_view, declaration, 'binding'))
        _row(binding, '${binding.text}: $type', ClassRowRole.member),
    ];
  }

  ClassMemberRow _row(RustViewNode node, String text, ClassRowRole role) =>
      ClassMemberRow(
        text: text,
        visibility: ClassMemberVisibility.public,
        nodeId: node.id,
        sourceLine: node.range.startLine,
        role: role,
      );
}
