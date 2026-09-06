import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'expression_parser.dart';
import 'token_stream.dart';

final class ReturnStatementParser {
  final NodeIdGenerator _nodeIdGenerator;

  ReturnStatementParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  ReturnStatementNode parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser, {
    required bool inSubroutine,
  }) {
    final returnToken = stream.advance();

    if (!inSubroutine) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.returnOutsideSubroutine,
          severity: Severity.error,
          span: returnToken.span,
        ),
      );
    }

    ExpressionNode? value;
    if (_hasReturnExpression(stream)) {
      value = expressionParser.parseExpression(stream, diagnostics);
    }

    final fullSpan = value != null
        ? stream.spanFrom(returnToken.span, value.span)
        : returnToken.span;

    return ReturnStatementNode(
      id: _nextId(),
      span: fullSpan,
      value: value,
    );
  }

  bool _hasReturnExpression(TokenStream stream) {
    if (stream.isAtEnd) return false;
    final type = stream.peek().type;
    return switch (type) {
      TokenType.endOfLine ||
      TokenType.semicolon ||
      TokenType.endSubroutine ||
      TokenType.endAlgorithm ||
      TokenType.endIf ||
      TokenType.elseKeyword ||
      TokenType.endWhile ||
      TokenType.until ||
      TokenType.endFor ||
      TokenType.endSwitch ||
      TokenType.defaultCase ||
      TokenType.endOfFile =>
        false,
      _ => true,
    };
  }
}
