import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'token_stream.dart';

final class SwitchCaseLabelValidator {
  const SwitchCaseLabelValidator._();

  static bool isLiteral(ExpressionNode expr) => switch (expr) {
        LiteralExpressionNode() => true,
        UnaryExpressionNode(:final operand)
            when operand is LiteralExpressionNode =>
          true,
        _ => false,
      };

  static bool isCaseLabelStart(TokenStream stream) {
    if (stream.isAtEnd) return false;
    final type = stream.peek().type;
    if (_isLiteralTokenType(type)) {
      return true;
    }
    if ((type == TokenType.plus || type == TokenType.minus) &&
        _isLiteralTokenType(stream.peekAhead(1).type)) {
      return true;
    }
    return false;
  }

  static bool _isLiteralTokenType(TokenType type) => switch (type) {
        TokenType.integerLiteral ||
        TokenType.realLiteral ||
        TokenType.stringLiteral ||
        TokenType.characterLiteral ||
        TokenType.booleanTrue ||
        TokenType.booleanFalse =>
          true,
        _ => false,
      };

  static void validateDuplicate(
    ExpressionNode expr,
    List<Diagnostic> diagnostics,
    Map<String, Span> seenLabels,
  ) {
    final key = extractLiteralKey(expr);
    if (key == null) return;

    final existingSpan = seenLabels[key];
    if (existingSpan != null) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.duplicateSwitchCaseLabel,
          severity: Severity.error,
          span: expr.span,
          arguments: {'lexeme': LexemeDiagnosticArgument(key)},
          relatedSpans: [existingSpan],
        ),
      );
    } else {
      seenLabels[key] = expr.span;
    }
  }

  static String? extractLiteralKey(ExpressionNode expr) => switch (expr) {
        LiteralExpressionNode(:final value) => value.toString(),
        UnaryExpressionNode(:final operator, :final operand)
            when operand is LiteralExpressionNode =>
          '${operator.name}_${operand.value}',
        _ => null,
      };
}
