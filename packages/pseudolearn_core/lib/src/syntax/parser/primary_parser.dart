import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/pseudo_integer.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'token_stream.dart';

final class PrimaryParser {
  final NodeIdGenerator _nodeIdGenerator;

  PrimaryParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  ExpressionNode parseLiteral(TokenStream stream) {
    final token = stream.advance();
    final (value, type) = _extractLiteralValueAndType(token);
    return LiteralExpressionNode(
      id: _nextId(),
      span: token.span,
      value: value,
      type: type,
    );
  }

  (Object, PrimitiveType) _extractLiteralValueAndType(Token token) =>
      switch (token.type) {
        TokenType.integerLiteral => (
            token.literalValue as PseudoInteger,
            PrimitiveType.integer
          ),
        TokenType.realLiteral => (
            token.literalValue as double,
            PrimitiveType.real
          ),
        TokenType.stringLiteral => (
            token.literalValue as String,
            PrimitiveType.string
          ),
        TokenType.characterLiteral => (
            token.literalValue as String,
            PrimitiveType.character
          ),
        TokenType.booleanTrue => (true, PrimitiveType.boolean),
        TokenType.booleanFalse => (false, PrimitiveType.boolean),
        _ => throw StateError('Unreachable literal token type: ${token.type}'),
      };

  ExpressionNode parseIdentifierOrCall(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final nameToken = stream.advance();
    if (stream.check(TokenType.leftParenthesis)) {
      return _parseFunctionCall(stream, diagnostics, nameToken, parseExpr);
    }
    return VariableExpressionNode(
      id: _nextId(),
      span: nameToken.span,
      name: nameToken.lexeme,
    );
  }

  ExpressionNode _parseFunctionCall(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Token nameToken,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final leftParen = stream.advance();
    final arguments = <ExpressionNode>[];

    if (stream.match(TokenType.rightParenthesis)) {
      return FunctionCallExpressionNode(
        id: _nextId(),
        span: stream.spanFrom(nameToken.span),
        name: nameToken.lexeme,
        nameSpan: nameToken.span,
        arguments: arguments,
      );
    }

    _parseArgumentList(stream, diagnostics, arguments, parseExpr);

    if (!stream.match(TokenType.rightParenthesis)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedParenthesis,
          severity: Severity.error,
          span: leftParen.span,
        ),
      );
    }

    return FunctionCallExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(nameToken.span),
      name: nameToken.lexeme,
      nameSpan: nameToken.span,
      arguments: arguments,
    );
  }

  void _parseArgumentList(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    List<ExpressionNode> arguments,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final firstArg = parseExpr(stream, diagnostics);
    if (firstArg != null) arguments.add(firstArg);

    while (stream.match(TokenType.comma)) {
      if (stream.check(TokenType.rightParenthesis)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.trailingComma,
            severity: Severity.error,
            span: stream.previousToken.span,
          ),
        );
        break;
      }
      final nextArg = parseExpr(stream, diagnostics);
      if (nextArg != null) arguments.add(nextArg);
    }
  }

  ExpressionNode? parseParenthesized(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final leftParen = stream.advance();
    if (stream.match(TokenType.rightParenthesis)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.emptyParentheses,
          severity: Severity.error,
          span: stream.spanFrom(leftParen.span),
        ),
      );
      return null;
    }

    final expression = parseExpr(stream, diagnostics);
    if (!stream.match(TokenType.rightParenthesis)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedParenthesis,
          severity: Severity.error,
          span: leftParen.span,
        ),
      );
    }
    if (expression == null) return null;

    return ParenthesizedExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(leftParen.span),
      expression: expression,
    );
  }

  ExpressionNode? parseArrayAccess(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode target,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final leftBracket = stream.advance();
    if (stream.match(TokenType.rightBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.emptyIndexList,
          severity: Severity.error,
          span: stream.spanFrom(leftBracket.span),
        ),
      );
      return null;
    }

    final indices = <ExpressionNode>[];
    _parseIndexList(stream, diagnostics, indices, parseExpr);
    _validateBracketClosure(stream, diagnostics, leftBracket.span);

    final accessNode = ArrayAccessExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(target.span),
      target: target,
      indices: indices,
    );

    _checkChainedArrayAccess(stream, diagnostics);
    return accessNode;
  }

  void _validateBracketClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Span leftBracketSpan,
  ) {
    if (!stream.match(TokenType.rightBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedBracket,
          severity: Severity.error,
          span: leftBracketSpan,
        ),
      );
    }
  }

  void _checkChainedArrayAccess(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.check(TokenType.leftBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.chainedArrayAccess,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }
  }

  void _parseIndexList(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    List<ExpressionNode> indices,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final firstIndex = parseExpr(stream, diagnostics);
    if (firstIndex != null) indices.add(firstIndex);

    while (stream.match(TokenType.comma)) {
      if (stream.check(TokenType.rightBracket)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.trailingComma,
            severity: Severity.error,
            span: stream.previousToken.span,
          ),
        );
        break;
      }
      final nextIndex = parseExpr(stream, diagnostics);
      if (nextIndex != null) indices.add(nextIndex);
    }
  }
}
