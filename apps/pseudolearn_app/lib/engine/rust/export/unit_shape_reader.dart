import '../rust_program_view.dart';
import 'statement_shape.dart';
import 'statement_shape_reader.dart';
import 'unit_shape.dart';

final class UnitShapeReader {
  final RustProgramView _view;
  final StatementShapeReader _statements;

  UnitShapeReader(this._view) : _statements = StatementShapeReader(_view);

  ProgramShape read() {
    final classes = <ClassShape>[];
    final subroutines = <SubroutineShape>[];
    List<StatementShape>? algorithm;
    for (final unit in _view.units) {
      final node = _view.nodeById(unit.nodeId);
      if (node == null) continue;
      switch (node.syntaxKind) {
        case 'class_unit':
          classes.add(_class(node));
        case 'subroutine':
          subroutines.add(_subroutine(node));
        case 'algorithm_unit':
          algorithm = _statements.block(_view.childForRole(node, 'body'));
      }
    }
    return ProgramShape(
      classes: classes,
      subroutines: subroutines,
      algorithm: algorithm,
      builtins: {
        for (final node in _view.nodes)
          if (node.semantics.builtin case final String identity) identity,
      },
    );
  }

  ClassShape _class(RustViewNode node) {
    final names = rustChildrenForRole(_view, node, 'name_or_base');
    final members = rustChildrenForRole(_view, node, 'member');
    return ClassShape(
      name: names.first.text,
      superclass: names.length > 1 ? names[1].text : null,
      fields: [
        for (final member in members)
          if (member.syntaxKind == 'field_declaration') ?_field(member),
      ],
      members: [
        for (final member in members)
          if (member.syntaxKind == 'constructor_member')
            ConstructorShape(_parameters(member), _body(member))
          else if (member.syntaxKind == 'method_member')
            _method(member),
      ],
    );
  }

  FieldShape? _field(RustViewNode member) {
    for (final child in rustChildrenOf(_view, member)) {
      if (child.syntaxKind != 'declaration') continue;
      final parts = rustChildrenOf(_view, child);
      final type = parts.where((part) => part.syntaxKind == 'type');
      if (type.isEmpty) return null;
      return FieldShape(_type(type.first), [
        for (final part in parts)
          if (part.syntaxKind == 'identifier') part.text,
      ]);
    }
    return null;
  }

  MethodShape _method(RustViewNode node) {
    final signature = rustChildrenForRole(_view, node, 'signature');
    final returns = signature.where((part) => part.syntaxKind == 'type');
    return MethodShape(
      signature.first.text,
      _parameters(node),
      _body(node),
      returnType: returns.isEmpty ? null : _type(returns.first),
    );
  }

  SubroutineShape _subroutine(RustViewNode node) {
    final parts = rustChildrenOf(_view, node);
    return SubroutineShape(parts.first.text, _parameters(node), _body(node));
  }

  List<StatementShape> _body(RustViewNode node) =>
      _statements.block(_view.childForRole(node, 'body') ?? _bodyChild(node));

  RustViewNode? _bodyChild(RustViewNode node) {
    for (final child in rustChildrenOf(_view, node)) {
      if (child.syntaxKind == 'body') return child;
    }
    return null;
  }

  List<ParameterShape> _parameters(RustViewNode node) {
    for (final child in rustChildrenOf(_view, node)) {
      if (child.syntaxKind != 'parameters') continue;
      return [
        for (final parameter in rustChildrenOf(_view, child))
          _parameter(parameter),
      ];
    }
    return const [];
  }

  ParameterShape _parameter(RustViewNode node) {
    final parts = rustChildrenOf(_view, node);
    return ParameterShape(parts.first.text, _type(parts.last));
  }

  TypeShape _type(RustViewNode node) =>
      TypeShape(primitive: node.semantics.primitive, text: node.text);
}
