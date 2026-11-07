import '../rust_program_view.dart';
import 'expression_types.dart';
import 'rust_expression_rules.dart';
import 'rust_helpers.dart';
import 'view_expression_writer.dart';

const Set<String> _arithmeticKinds = {'addition', 'multiplication'};
const Set<String> _comparisonKinds = {'equality', 'ordering'};
const Set<String> _operandKinds = {
  'identifier',
  'primary',
  'postfix',
  'literal',
};

/// Rust has no implicit numeric conversions: an integer that meets a real,
/// a division or a real destination is converted with `as f64`, as the engine
/// does implicitly.
final class RustExpressionWriter extends ViewExpressionWriter {
  final ExpressionTypes types;
  final RustHelpers helpers;

  RustExpressionWriter(RustProgramView view, this.types, this.helpers)
    : super(view, const RustExpressionRules());

  /// [node] written for a destination of type [primitive].
  String writeAs(RustViewNode node, String? primitive) =>
      primitive == 'real' && types.of(node) == 'integer'
      ? _toReal(node)
      : write(node);

  String _toReal(RustViewNode node) {
    final literal = node.semantics.literal;
    if (literal != null && literal.type == 'integer') {
      return '${literal.value}.0';
    }
    final text = write(node);
    return _operandKinds.contains(node.syntaxKind)
        ? '$text as f64'
        : '($text) as f64';
  }

  @override
  List<String> callArguments(String callee, RustViewNode container) {
    final parameters = types.signatureOf(callee)?.parameters ?? const [];
    final arguments = rustChildrenOf(programView, container);
    return [
      for (var index = 0; index < arguments.length; index++)
        writeAs(
          arguments[index],
          index < parameters.length ? parameters[index] : null,
        ),
    ];
  }

  @override
  String writeBinary(RustViewNode node) {
    final operands = rustChildrenOf(programView, node);
    final operators = node.semantics.operators;
    if (operators.length != operands.length - 1) return super.writeBinary(node);
    if (_comparisonKinds.contains(node.syntaxKind) &&
        operands.any((operand) => types.of(operand) == 'real')) {
      return _join(operands, operators, (operand) => writeAs(operand, 'real'));
    }
    if (_arithmeticKinds.contains(node.syntaxKind) &&
        types.of(node) == 'real') {
      return _realArithmetic(operands, operators);
    }
    return super.writeBinary(node);
  }

  String _join(
    List<RustViewNode> operands,
    List<String> operators,
    String Function(RustViewNode) operand,
  ) {
    final buffer = StringBuffer(operand(operands.first));
    for (var index = 0; index < operators.length; index++) {
      buffer.write(' ${_symbol(operators[index])} ');
      buffer.write(operand(operands[index + 1]));
    }
    return buffer.toString();
  }

  /// Left to right, as the engine evaluates: the running value stays an
  /// integer until a division or a real operand turns it into a real.
  String _realArithmetic(List<RustViewNode> operands, List<String> operators) {
    var text = write(operands.first);
    var real = types.of(operands.first) == 'real';
    for (var index = 0; index < operators.length; index++) {
      final operator = operators[index];
      final right = operands[index + 1];
      final becomesReal =
          real || operator == 'divide' || types.of(right) == 'real';
      if (becomesReal && !real) {
        text = index == 0 ? _toReal(operands.first) : '($text) as f64';
      }
      final rightText = becomesReal ? writeAs(right, 'real') : write(right);
      text = operator == 'divide' && !_isNonZeroLiteral(right)
          ? helpers.divide(text, rightText)
          : '$text ${_symbol(operator)} $rightText';
      real = becomesReal;
    }
    return text;
  }

  bool _isNonZeroLiteral(RustViewNode node) {
    final literal = node.semantics.literal;
    if (literal == null) return false;
    final value = num.tryParse(literal.value);
    return value != null && value != 0;
  }

  String _symbol(String operator) =>
      const RustExpressionRules().binaryOperators[operator] ?? operator;
}
