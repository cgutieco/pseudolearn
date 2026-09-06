import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'designator_validator.dart';
import 'expression_parser.dart';
import 'token_stream.dart';

final class IoStatementParser {
  final NodeIdGenerator _nodeIdGenerator;

  IoStatementParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  WriteStatementNode parseWrite(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final writeToken = stream.advance();
    _checkPrematureModifier(stream, diagnostics);

    final expressions = _parseWriteExpressions(
      stream,
      diagnostics,
      expressionParser,
    );
    final (withoutNewline, modifierSpan) = _parseWithoutNewlineModifier(
      stream,
      diagnostics,
    );

    return WriteStatementNode(
      id: _nextId(),
      span: stream.spanFrom(writeToken.span),
      expressions: expressions,
      withoutNewline: withoutNewline,
      withoutNewlineSpan: modifierSpan,
    );
  }

  void _checkPrematureModifier(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.check(TokenType.withoutNewline)) {
      final modifierToken = stream.peek();
      final afterModifier = stream.peekAhead(1).type;
      final isStatementEnd = afterModifier == TokenType.endOfLine ||
          afterModifier == TokenType.semicolon ||
          afterModifier == TokenType.endOfFile;

      if (!isStatementEnd) {
        stream.advance();
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.unexpectedModifierPosition,
            severity: Severity.error,
            span: modifierToken.span,
          ),
        );
      }
    }
  }

  List<ExpressionNode> _parseWriteExpressions(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final expressions = <ExpressionNode>[];
    if (_isWriteTerminator(stream.peek().type)) {
      return expressions;
    }

    final first = expressionParser.parseExpression(stream, diagnostics);
    if (first != null) expressions.add(first);

    while (stream.match(TokenType.comma)) {
      if (_isWriteTerminator(stream.peek().type)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.trailingComma,
            severity: Severity.error,
            span: stream.previousToken.span,
          ),
        );
        break;
      }
      final next = expressionParser.parseExpression(stream, diagnostics);
      if (next != null) expressions.add(next);
    }
    return expressions;
  }

  bool _isWriteTerminator(TokenType type) => switch (type) {
        TokenType.endOfLine ||
        TokenType.semicolon ||
        TokenType.endOfFile ||
        TokenType.withoutNewline =>
          true,
        _ => false,
      };

  (bool, Span?) _parseWithoutNewlineModifier(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.match(TokenType.withoutNewline)) {
      return (false, null);
    }
    final modifierSpan = stream.previousToken.span;
    if (stream.match(TokenType.withoutNewline)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.duplicateModifier,
          severity: Severity.error,
          span: stream.previousToken.span,
        ),
      );
    }
    return (true, modifierSpan);
  }

  ReadStatementNode? parseRead(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final readToken = stream.advance();
    if (_isReadTerminator(stream.peek().type)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedReadTarget,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
      return null;
    }

    final targets = _parseReadTargets(stream, diagnostics, expressionParser);
    if (targets.isEmpty) return null;

    return ReadStatementNode(
      id: _nextId(),
      span: stream.spanFrom(readToken.span),
      targets: targets,
    );
  }

  List<ExpressionNode> _parseReadTargets(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final targets = <ExpressionNode>[];
    final first =
        _parseAndValidateTarget(stream, diagnostics, expressionParser);
    if (first != null) targets.add(first);

    while (stream.match(TokenType.comma)) {
      if (_isReadTerminator(stream.peek().type)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.trailingComma,
            severity: Severity.error,
            span: stream.previousToken.span,
          ),
        );
        break;
      }
      final next = _parseAndValidateTarget(
        stream,
        diagnostics,
        expressionParser,
      );
      if (next != null) targets.add(next);
    }
    return targets;
  }

  ExpressionNode? _parseAndValidateTarget(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final target = expressionParser.parseExpression(stream, diagnostics);
    if (target == null) return null;

    if (!DesignatorValidator.isDesignator(target)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.invalidReadTarget,
          severity: Severity.error,
          span: target.span,
        ),
      );
      return null;
    }
    return target;
  }

  bool _isReadTerminator(TokenType type) => switch (type) {
        TokenType.endOfLine ||
        TokenType.semicolon ||
        TokenType.endOfFile =>
          true,
        _ => false,
      };
}
