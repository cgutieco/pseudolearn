import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import '../ast/operators.dart';
import 'expression_parse_result.dart';
import 'oop_expression_parser.dart';
import 'operator_precedence.dart';
import 'primary_parser.dart';
import 'token_stream.dart';

final class ExpressionParser {
  final NodeIdGenerator _nodeIdGenerator;
  final PrimaryParser _primaryParser;
  final OopExpressionParser _oopParser;

  ExpressionParser([NodeIdGenerator? nodeIdGenerator])
      : this._(nodeIdGenerator ?? NodeIdGenerator());

  ExpressionParser._(NodeIdGenerator generator)
      : _nodeIdGenerator = generator,
        _primaryParser = PrimaryParser(generator),
        _oopParser = OopExpressionParser(generator);

  ExpressionParseResult parse(TokenStream stream) {
    final diagnostics = <Diagnostic>[];
    final expression = parseExpression(
      stream,
      diagnostics,
      OperatorPrecedence.lowest,
    );
    return ExpressionParseResult(
      expression: expression,
      diagnostics: diagnostics,
    );
  }

  ExpressionNode? parseExpression(
    TokenStream stream,
    List<Diagnostic> diagnostics, [
    int precedence = OperatorPrecedence.lowest,
  ]) {
    var left = _parsePrefix(stream, diagnostics);
    if (left == null) return null;

    while (!stream.isAtEnd) {
      final nextType = stream.peek().type;
      final infixPrecedence = OperatorPrecedence.getInfixPrecedence(nextType);
      if (infixPrecedence <= precedence) break;

      final currentLeft = left!;
      if (nextType == TokenType.leftBracket) {
        left = _primaryParser.parseArrayAccess(
          stream,
          diagnostics,
          currentLeft,
          (s, d) => parseExpression(s, d, OperatorPrecedence.lowest),
        );
      } else if (nextType == TokenType.dot) {
        left = _oopParser.parseMemberAccessOrCall(
          stream,
          diagnostics,
          currentLeft,
          (s, d) => parseExpression(s, d, OperatorPrecedence.lowest),
        );
      } else {
        left = _parseBinary(stream, diagnostics, currentLeft, infixPrecedence);
      }
      if (left == null) break;
    }

    return left;
  }

  NodeId _nextId() => _nodeIdGenerator.next();

  ExpressionNode? _parsePrefix(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.isAtEnd) {
      _reportExpectedExpression(stream, diagnostics);
      return null;
    }
    final token = stream.peek();
    final unaryOp = OperatorPrecedence.getUnaryOperator(token.type);
    if (unaryOp != null) {
      return _parseUnary(stream, diagnostics, unaryOp);
    }
    return _dispatchPrefixToken(stream, diagnostics, token.type);
  }

  ExpressionNode? _dispatchPrefixToken(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    TokenType type,
  ) =>
      switch (type) {
        TokenType.integerLiteral ||
        TokenType.realLiteral ||
        TokenType.stringLiteral ||
        TokenType.characterLiteral ||
        TokenType.booleanTrue ||
        TokenType.booleanFalse =>
          _primaryParser.parseLiteral(stream),
        TokenType.identifier => _primaryParser.parseIdentifierOrCall(
            stream,
            diagnostics,
            (s, d) => parseExpression(s, d, OperatorPrecedence.lowest),
          ),
        TokenType.leftParenthesis => _primaryParser.parseParenthesized(
            stream,
            diagnostics,
            (s, d) => parseExpression(s, d, OperatorPrecedence.lowest),
          ),
        TokenType.newInstance => _oopParser.parseInstantiation(
            stream,
            diagnostics,
            (s, d) => parseExpression(s, d, OperatorPrecedence.lowest),
          ),
        TokenType.thisObject => _oopParser.parseThis(stream),
        TokenType.superClass => _oopParser.parseSuper(stream),
        _ => _handleUnexpectedPrefixToken(stream, diagnostics),
      };

  ExpressionNode? _parseUnary(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    UnaryOperator unaryOp,
  ) {
    final operatorToken = stream.advance();
    final operand = parseExpression(
      stream,
      diagnostics,
      OperatorPrecedence.unaryPrecedence,
    );
    if (operand == null) {
      _reportExpectedExpression(stream, diagnostics);
      return null;
    }
    return UnaryExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(operatorToken.span, operand.span),
      operator: unaryOp,
      operand: operand,
      operatorSpan: operatorToken.span,
    );
  }

  ExpressionNode? _parseBinary(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode left,
    int infixPrecedence,
  ) {
    final operatorToken = stream.advance();
    final binaryOp = OperatorPrecedence.getBinaryOperator(operatorToken.type)!;
    final isRightAssoc = OperatorPrecedence.isRightAssociative(
      operatorToken.type,
    );
    final rightPrecedence =
        isRightAssoc ? infixPrecedence - 1 : infixPrecedence;

    final right = parseExpression(stream, diagnostics, rightPrecedence);
    if (right == null) {
      _reportExpectedExpression(stream, diagnostics);
      return null;
    }

    return BinaryExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(left.span, right.span),
      left: left,
      operator: binaryOp,
      right: right,
      operatorSpan: operatorToken.span,
    );
  }

  ExpressionNode? _handleUnexpectedPrefixToken(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final token = stream.peek();
    if (token.type == TokenType.rightParenthesis) {
      stream.advance();
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unexpectedClosingParenthesis,
          severity: Severity.error,
          span: token.span,
        ),
      );
      return null;
    }
    if (_isFollowToken(token.type)) {
      _reportExpectedExpression(stream, diagnostics);
      return null;
    }
    stream.advance();
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.unexpectedTokenInExpression,
        severity: Severity.error,
        span: token.span,
        arguments: {'lexeme': LexemeDiagnosticArgument(token.lexeme)},
      ),
    );
    return null;
  }

  bool _isFollowToken(TokenType type) => switch (type) {
        TokenType.endOfLine ||
        TokenType.endOfFile ||
        TokenType.semicolon ||
        TokenType.comma ||
        TokenType.rightBracket =>
          true,
        _ => false,
      };

  void _reportExpectedExpression(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final span =
        stream.isAtEnd ? stream.previousToken.span : stream.peek().span;
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.expectedExpression,
        severity: Severity.error,
        span: span,
      ),
    );
  }
}
