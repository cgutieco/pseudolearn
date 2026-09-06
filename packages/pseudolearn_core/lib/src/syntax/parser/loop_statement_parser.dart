import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'expression_parser.dart';
import 'statement_synchronizer.dart';
import 'token_stream.dart';

typedef BodyParser = List<StatementNode> Function(
  TokenStream stream,
  List<Diagnostic> diagnostics,
  Set<TokenType> stopTokens, {
  bool Function(TokenStream stream)? isStopPredicate,
});

final class LoopStatementParser {
  final NodeIdGenerator _nodeIdGenerator;

  LoopStatementParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  WhileStatementNode parseWhile(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    BodyParser parseBody,
  ) {
    final whileToken = stream.advance();
    final condition = _parseCondition(stream, diagnostics, expressionParser);

    if (!stream.match(TokenType.doKeyword)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedDoKeyword,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }

    final body = parseBody(stream, diagnostics, {
      TokenType.endWhile,
      TokenType.endAlgorithm,
      TokenType.endOfFile,
    });

    _validateBlockClosure(
      stream,
      diagnostics,
      TokenType.endWhile,
      DiagnosticCode.unclosedWhileStatement,
      openSpan: whileToken.span,
    );

    return WhileStatementNode(
      id: _nextId(),
      span: stream.spanFrom(whileToken.span),
      condition: condition,
      body: body,
    );
  }

  RepeatUntilStatementNode parseRepeatUntil(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    BodyParser parseBody,
  ) {
    final repeatToken = stream.advance();
    final body = parseBody(stream, diagnostics, {
      TokenType.until,
      TokenType.endAlgorithm,
      TokenType.endOfFile,
    });

    if (!stream.match(TokenType.until)) {
      return _handleUnclosedRepeat(
        stream,
        diagnostics,
        expressionParser,
        repeatSpan: repeatToken.span,
        body: body,
      );
    }

    final untilSpan = stream.previousToken.span;
    final condition = _parseCondition(stream, diagnostics, expressionParser);

    return RepeatUntilStatementNode(
      id: _nextId(),
      span: stream.spanFrom(repeatToken.span),
      body: body,
      condition: condition,
      untilKeywordSpan: untilSpan,
    );
  }

  RepeatUntilStatementNode _handleUnclosedRepeat(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser, {
    required Span repeatSpan,
    required List<StatementNode> body,
  }) {
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.unclosedRepeatStatement,
        severity: Severity.error,
        span: stream.peek().span,
        relatedSpans: [repeatSpan],
      ),
    );
    final fallbackCondition = _parseCondition(
      stream,
      diagnostics,
      expressionParser,
    );
    return RepeatUntilStatementNode(
      id: _nextId(),
      span: stream.spanFrom(repeatSpan),
      body: body,
      condition: fallbackCondition,
      untilKeywordSpan: repeatSpan,
    );
  }

  ExpressionNode _parseCondition(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final expr = expressionParser.parseExpression(stream, diagnostics);
    if (expr != null) return expr;
    return LiteralExpressionNode(
      id: _nextId(),
      span: stream.peek().span,
      value: false,
      type: PrimitiveType.boolean,
    );
  }

  void _validateBlockClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    TokenType expectedClosing,
    DiagnosticCode unclosedCode, {
    required Span openSpan,
  }) {
    StatementSynchronizer.skipIgnoredDelimiters(stream);
    if (!stream.match(expectedClosing)) {
      diagnostics.add(
        Diagnostic(
          code: unclosedCode,
          severity: Severity.error,
          span: stream.peek().span,
          relatedSpans: [openSpan],
        ),
      );
    }
  }
}
