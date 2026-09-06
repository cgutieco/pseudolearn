import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/parser_profile.dart';
import '../../domain/severity.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'designator_validator.dart';
import 'expression_parser.dart';
import 'reserved_lexeme_name.dart';
import 'statement_synchronizer.dart';
import 'token_stream.dart';
import 'top_level_collector.dart';

final class AssignmentAndCallParser {
  final NodeIdGenerator _nodeIdGenerator;
  final ParserProfile _profile;

  AssignmentAndCallParser(this._nodeIdGenerator, this._profile);

  NodeId _nextId() => _nodeIdGenerator.next();

  StatementNode? parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final token = stream.peek();
    if (StatementSynchronizer.isKnownUnsupportedKeyword(token.lexeme)) {
      return _handleUnsupportedConstruct(stream, diagnostics, token);
    }
    if (_isReservedNameBeforeAssignment(stream)) {
      stream.advance();
      diagnostics.add(ReservedLexemeName.diagnosticFor(token));
      return null;
    }

    final target = expressionParser.parseExpression(stream, diagnostics);
    if (target == null) {
      return _handleNullTarget(stream, diagnostics);
    }

    if (stream.match(TokenType.assignment)) {
      return _parseAssignment(stream, diagnostics, expressionParser, target);
    }

    return _dispatchCallOrUnexpected(diagnostics, target, token);
  }

  bool _isReservedNameBeforeAssignment(TokenStream stream) =>
      ReservedLexemeName.standsWhereNameIsRequired(stream.peek()) &&
      stream.peekAhead(1).type == TokenType.assignment;

  StatementNode? _dispatchCallOrUnexpected(
    List<Diagnostic> diagnostics,
    ExpressionNode target,
    Token token,
  ) {
    if (target is FunctionCallExpressionNode) {
      return CallStatementNode(
        id: _nextId(),
        span: target.span,
        name: target.name,
        nameSpan: target.nameSpan,
        arguments: target.arguments,
      );
    }
    if (target is MethodCallExpressionNode) {
      return MethodCallStatementNode(
        id: _nextId(),
        span: target.span,
        target: target.target,
        methodName: target.methodName,
        methodSpan: target.methodSpan,
        arguments: target.arguments,
      );
    }
    return _handleUnexpectedStatementTarget(diagnostics, target, token);
  }

  StatementNode? _handleUnexpectedStatementTarget(
    List<Diagnostic> diagnostics,
    ExpressionNode target,
    Token token,
  ) {
    if (target is VariableExpressionNode) {
      final unsupported =
          _profile.unsupportedConstructs[target.name.toLowerCase()];
      if (unsupported != null) {
        diagnostics.add(
          Diagnostic(
            code: diagnosticForUnsupportedConstruct(unsupported),
            severity: Severity.error,
            span: target.span,
          ),
        );
        return null;
      }
    }
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.unexpectedStatement,
        severity: Severity.error,
        span: target.span,
        arguments: {'lexeme': LexemeDiagnosticArgument(token.lexeme)},
      ),
    );
    return null;
  }

  StatementNode? _parseAssignment(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    ExpressionNode target,
  ) {
    final assignToken = stream.previousToken;
    if (!DesignatorValidator.isDesignator(target)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.invalidAssignmentTarget,
          severity: Severity.error,
          span: target.span,
        ),
      );
    }

    final value = expressionParser.parseExpression(stream, diagnostics);
    if (value == null) return null;

    return AssignmentStatementNode(
      id: _nextId(),
      span: stream.spanFrom(target.span, value.span),
      target: target,
      value: value,
      assignmentOperatorSpan: assignToken.span,
    );
  }

  StatementNode? _handleUnsupportedConstruct(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Token token,
  ) {
    stream.advance();
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.unsupportedStructuredConstruct,
        severity: Severity.error,
        span: token.span,
        arguments: {'lexeme': LexemeDiagnosticArgument(token.lexeme)},
      ),
    );
    return null;
  }

  StatementNode? _handleNullTarget(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.isAtEnd && stream.peek().type != TokenType.endOfLine) {
      final token = stream.advance();
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unexpectedStatement,
          severity: Severity.error,
          span: token.span,
          arguments: {'lexeme': LexemeDiagnosticArgument(token.lexeme)},
        ),
      );
    }
    return null;
  }
}
