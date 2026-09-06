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

final class IfStatementParser {
  final NodeIdGenerator _nodeIdGenerator;

  IfStatementParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  IfStatementNode parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    BodyParser parseBody,
  ) {
    final ifToken = stream.advance();
    final condition = _parseCondition(stream, diagnostics, expressionParser);
    _validateThenKeyword(stream, diagnostics);

    final thenBody = parseBody(stream, diagnostics, {
      TokenType.elseKeyword,
      TokenType.endIf,
      TokenType.endAlgorithm,
      TokenType.endOfFile,
    });

    final (elseBody, elseSpan) = _parseOptionalElse(
      stream,
      diagnostics,
      parseBody,
    );

    _validateClosure(stream, diagnostics, ifToken.span);

    return IfStatementNode(
      id: _nextId(),
      span: stream.spanFrom(ifToken.span),
      condition: condition,
      thenBody: thenBody,
      elseBody: elseBody,
      elseKeywordSpan: elseSpan,
    );
  }

  void _validateThenKeyword(TokenStream stream, List<Diagnostic> diagnostics) {
    if (!stream.match(TokenType.then)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedThenKeyword,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }
  }

  (List<StatementNode>?, Span?) _parseOptionalElse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    BodyParser parseBody,
  ) {
    if (!stream.match(TokenType.elseKeyword)) {
      return (null, null);
    }
    final elseKeywordSpan = stream.previousToken.span;
    final elseBody = parseBody(stream, diagnostics, {
      TokenType.elseKeyword,
      TokenType.endIf,
      TokenType.endAlgorithm,
      TokenType.endOfFile,
    });

    if (stream.match(TokenType.elseKeyword)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.duplicateElseClause,
          severity: Severity.error,
          span: stream.previousToken.span,
        ),
      );
    }
    return (elseBody, elseKeywordSpan);
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

  void _validateClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Span ifSpan,
  ) {
    StatementSynchronizer.skipIgnoredDelimiters(stream);
    if (!stream.match(TokenType.endIf)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedIfStatement,
          severity: Severity.error,
          span: stream.peek().span,
          relatedSpans: [ifSpan],
        ),
      );
    }
  }
}
