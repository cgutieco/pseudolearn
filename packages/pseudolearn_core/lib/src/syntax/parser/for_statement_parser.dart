import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/profile/parser_profile.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'expression_parser.dart';
import 'reserved_lexeme_name.dart';
import 'statement_synchronizer.dart';
import 'token_stream.dart';

const Set<TokenType> _forVariableContinuation = {
  TokenType.to,
  TokenType.step,
  TokenType.doKeyword,
};

typedef BodyParser = List<StatementNode> Function(
  TokenStream stream,
  List<Diagnostic> diagnostics,
  Set<TokenType> stopTokens, {
  bool Function(TokenStream stream)? isStopPredicate,
});

final class ForStatementParser {
  final NodeIdGenerator _nodeIdGenerator;
  final ParserProfile _profile;

  ForStatementParser(this._nodeIdGenerator, this._profile);

  NodeId _nextId() => _nodeIdGenerator.next();

  ForStatementNode parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    BodyParser parseBody,
  ) {
    final forToken = stream.advance();
    final (variable, from, to, step) = _parseForHeader(
      stream,
      diagnostics,
      expressionParser,
    );

    final body = parseBody(stream, diagnostics, {
      TokenType.endFor,
      TokenType.endAlgorithm,
      TokenType.endOfFile,
    });

    _validateClosure(stream, diagnostics, forToken.span);

    return ForStatementNode(
      id: _nextId(),
      span: stream.spanFrom(forToken.span),
      variable: variable,
      from: from,
      to: to,
      step: step,
      body: body,
    );
  }

  (VariableExpressionNode, ExpressionNode, ExpressionNode, ExpressionNode?)
      _parseForHeader(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final variable = _parseForVariable(stream, diagnostics);
    final (from, to) = _parseForBounds(stream, diagnostics, expressionParser);
    final step = _parseForStep(stream, diagnostics, expressionParser);

    if (!stream.match(TokenType.doKeyword)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedDoKeyword,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }

    return (variable, from, to, step);
  }

  (ExpressionNode, ExpressionNode) _parseForBounds(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    if (!stream.match(TokenType.assignment)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedAssignmentOperator,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }

    final from = _parseCondition(stream, diagnostics, expressionParser);

    if (!stream.match(TokenType.to)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedToKeyword,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }

    final to = _parseCondition(stream, diagnostics, expressionParser);
    return (from, to);
  }

  VariableExpressionNode _parseForVariable(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.check(TokenType.identifier)) {
      final token = stream.peek();
      _reportMissingForVariable(stream, diagnostics);
      return VariableExpressionNode(
        id: _nextId(),
        span: token.span,
        name: '',
      );
    }
    final token = stream.advance();
    return VariableExpressionNode(
      id: _nextId(),
      span: token.span,
      name: token.lexeme,
    );
  }

  void _reportMissingForVariable(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final token = stream.peek();
    if (ReservedLexemeName.standsWhereNameIsRequired(
      token,
      continuesWith: _forVariableContinuation,
    )) {
      stream.advance();
      diagnostics.add(ReservedLexemeName.diagnosticFor(token));
      return;
    }
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.expectedForLoopVariable,
        severity: Severity.error,
        span: token.span,
      ),
    );
  }

  ExpressionNode? _parseForStep(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    if (stream.match(TokenType.step)) {
      return expressionParser.parseExpression(stream, diagnostics);
    }
    if (_profile.mandatoryStepInCountedLoop) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.missingStepClause,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }
    return null;
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
    Span openSpan,
  ) {
    StatementSynchronizer.skipIgnoredDelimiters(stream);
    if (!stream.match(TokenType.endFor)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedForStatement,
          severity: Severity.error,
          span: stream.peek().span,
          relatedSpans: [openSpan],
        ),
      );
    }
  }
}
