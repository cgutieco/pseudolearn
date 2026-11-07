import '../rust_program_view.dart';
import 'expression_types.dart';
import 'python_expression_rules.dart';
import 'view_expression_writer.dart';

/// An integer stored in a real destination stays an `int` in Python and
/// prints without decimals; it is converted with `float` as the engine does.
final class PythonExpressionWriter extends ViewExpressionWriter {
  final ExpressionTypes types;

  PythonExpressionWriter(RustProgramView view, this.types)
    : super(view, const PythonExpressionRules());

  /// [node] written for a destination of type [primitive].
  String writeAs(RustViewNode node, String? primitive) {
    if (primitive != 'real' || types.of(node) != 'integer') return write(node);
    final literal = node.semantics.literal;
    if (literal != null && literal.type == 'integer') {
      return '${literal.value}.0';
    }
    return 'float(${write(node)})';
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
}
