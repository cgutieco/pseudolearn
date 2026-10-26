import '../../../domain/model/analysis/program_node_id.dart';
import '../rust_program_view.dart';
import 'statement_shape.dart';

final class StatementShapeReader {
  final RustProgramView _view;

  const StatementShapeReader(this._view);

  List<StatementShape> block(RustViewNode? body) {
    if (body == null) return const [];
    return [
      for (final child in rustChildrenOf(_view, body))
        if (body.childRoles[child.id.value] == 'statement') _statement(child),
    ];
  }

  StatementShape _statement(RustViewNode wrapper) {
    final node = _inner(wrapper);
    final id = wrapper.id;
    final parts = rustChildrenOf(_view, node);
    return switch (node.syntaxKind) {
      'assignment_statement' => AssignmentShape(id, parts.first, parts.last),
      'declaration' => DeclarationShape(
        id,
        _names(node, parts),
        _initializer(node, parts),
      ),
      'dimension_declaration' => DimensionShape(id, _arrays(parts)),
      'output' => WriteShape(id, parts, node.semantics.withoutNewline),
      'input' => ReadShape(id, parts),
      'conditional' => _conditional(id, node),
      'while_loop' => WhileShape(
        id,
        _role(node, 'condition')!,
        block(_role(node, 'body')),
      ),
      'repeat_loop' => RepeatShape(
        id,
        _role(node, 'condition')!,
        block(_role(node, 'body')),
      ),
      'for_loop' => _forLoop(id, node),
      'switch' => _switch(id, node),
      'return_statement' => ReturnShape(id, parts.isEmpty ? null : parts.first),
      'call_statement' => _call(id, parts.first),
      _ => UnsupportedShape(id),
    };
  }

  RustViewNode _inner(RustViewNode wrapper) {
    for (final child in rustChildrenOf(_view, wrapper)) {
      if (wrapper.childRoles[child.id.value] == 'statement') return child;
    }
    return wrapper;
  }

  RustViewNode? _role(RustViewNode node, String role) =>
      _view.childForRole(node, role);

  List<String> _names(RustViewNode node, List<RustViewNode> parts) => [
    for (final part in parts)
      if (node.childRoles[part.id.value] == 'binding' &&
          part.syntaxKind == 'identifier')
        part.text,
  ];

  RustViewNode? _initializer(RustViewNode node, List<RustViewNode> parts) {
    for (final part in parts) {
      if (node.childRoles[part.id.value] == 'initializer') return part;
    }
    return null;
  }

  List<ArrayShape> _arrays(List<RustViewNode> parts) => [
    for (final part in parts)
      if (part.syntaxKind == 'dimensioned') _array(part),
  ];

  ArrayShape _array(RustViewNode dimensioned) {
    final parts = rustChildrenOf(_view, dimensioned);
    return ArrayShape(parts.first.text, parts.skip(1).toList());
  }

  StatementShape _conditional(ProgramNodeId id, RustViewNode node) => IfShape(
    id,
    condition: _role(node, 'condition')!,
    thenBody: block(_role(node, 'then_body')),
    elseBody: block(_role(node, 'else_body')),
  );

  StatementShape _forLoop(ProgramNodeId id, RustViewNode node) {
    final header = rustChildrenForRole(_view, node, 'loop_header');
    return ForShape(
      id,
      variable: header.first.text,
      from: header[1],
      to: header[2],
      step: header.length > 3 ? header[3] : null,
      body: block(_role(node, 'body')),
    );
  }

  StatementShape _switch(ProgramNodeId id, RustViewNode node) {
    final defaultCase = _role(node, 'default_case');
    return SwitchShape(
      id,
      selector: _role(node, 'selector')!,
      cases: [
        for (final branch in rustChildrenForRole(_view, node, 'case'))
          CaseShape(_labels(branch), block(_role(branch, 'body'))),
      ],
      defaultBody: defaultCase == null
          ? null
          : block(_role(defaultCase, 'body')),
    );
  }

  List<RustViewNode> _labels(RustViewNode branch) {
    final labels = _role(branch, 'labels');
    return labels == null ? const [] : rustChildrenOf(_view, labels);
  }

  StatementShape _call(ProgramNodeId id, RustViewNode postfix) {
    final parts = rustChildrenOf(_view, postfix);
    final container = parts.last;
    final arguments = rustChildrenOf(_view, container);
    if (parts.length == 2 && postfix.semantics.receiver != 'super') {
      return CallShape(id, parts.first.text, arguments);
    }
    return MethodCallShape(
      id,
      call: postfix,
      target: parts.take(parts.length - 2).toList(),
      methodName: parts[parts.length - 2].text,
      arguments: arguments,
    );
  }
}
