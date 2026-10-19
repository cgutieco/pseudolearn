import '../rust_program_view.dart';
import 'view_expression_rules.dart';

const Set<String> _binaryKinds = {
  'addition',
  'and',
  'conjunction',
  'disjunction',
  'divide',
  'equality',
  'integer_divide',
  'modulo',
  'multiplication',
  'or',
  'ordering',
  'power',
  'power_expression',
};

final class ViewExpressionWriter {
  final RustProgramView _view;
  final ViewExpressionRules _rules;

  const ViewExpressionWriter(this._view, this._rules);

  String write(RustViewNode node) {
    return switch (node.syntaxKind) {
      'literal' => _literal(node),
      'identifier' => node.text,
      'this_object' => _rules.thisText,
      'primary' => '(${_first(node)})',
      'unary' => _unary(node),
      'postfix' => writeChain(rustChildrenOf(_view, node), node),
      'instantiation' => _instantiation(node),
      final kind when _binaryKinds.contains(kind) => _binary(node),
      _ => node.text,
    };
  }

  bool isNegation(RustViewNode node) =>
      node.syntaxKind == 'unary' && node.semantics.operator == 'negate';

  List<String> arguments(RustViewNode? container) => container == null
      ? const []
      : [for (final child in rustChildrenOf(_view, container)) write(child)];

  String writeChain(List<RustViewNode> parts, RustViewNode owner) {
    final builtin = owner.semantics.builtin;
    if (builtin != null && parts.length == 2) {
      return _rules.builtin(builtin, arguments(parts.last));
    }
    var text = owner.semantics.receiver == 'super'
        ? _rules.superText
        : write(parts.first);
    final suffixes = owner.semantics.receiver == 'super'
        ? parts
        : parts.skip(1);
    for (final part in suffixes) {
      text += _suffix(part);
    }
    return text;
  }

  String _suffix(RustViewNode part) => switch (part.syntaxKind) {
    'arguments' => '(${arguments(part).join(', ')})',
    'expressions' => arguments(part).map(_rules.index).join(),
    _ => '.${part.text}',
  };

  String _first(RustViewNode node) {
    final children = rustChildrenOf(_view, node);
    return children.isEmpty ? node.text : write(children.first);
  }

  String _literal(RustViewNode node) {
    final literal = node.semantics.literal;
    return literal == null ? node.text : _rules.literal(literal);
  }

  String _unary(RustViewNode node) {
    final operator = node.semantics.operator;
    final operand = rustChildrenOf(_view, node);
    if (operator == null || operand.isEmpty) return node.text;
    return _rules.unary(operator, write(operand.first));
  }

  String _instantiation(RustViewNode node) {
    final children = rustChildrenOf(_view, node);
    if (children.isEmpty) return node.text;
    final container = children.length > 1 ? children[1] : null;
    return _rules.instantiation(children.first.text, arguments(container));
  }

  String _binary(RustViewNode node) {
    final operands = rustChildrenOf(_view, node);
    final operators = node.semantics.operators;
    if (operators.length != operands.length - 1) return node.text;
    final buffer = StringBuffer(write(operands.first));
    for (var index = 0; index < operators.length; index++) {
      buffer.write(' ${(_rules.binaryOperators[operators[index]] ?? operators[index])} ');
      buffer.write(write(operands[index + 1]));
    }
    return buffer.toString();
  }
}
