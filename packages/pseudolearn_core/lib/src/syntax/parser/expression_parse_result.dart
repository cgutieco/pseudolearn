import '../../domain/diagnostic.dart';
import '../../domain/severity.dart';
import '../ast/ast_node.dart';

final class ExpressionParseResult {
  final ExpressionNode? expression;
  final List<Diagnostic> diagnostics;

  const ExpressionParseResult({
    required this.expression,
    required this.diagnostics,
  });

  bool get hasErrors =>
      diagnostics.any((diagnostic) => diagnostic.severity == Severity.error);
}
