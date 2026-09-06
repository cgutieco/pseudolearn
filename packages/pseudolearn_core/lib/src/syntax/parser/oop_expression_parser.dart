import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'token_stream.dart';

final class OopExpressionParser {
  final NodeIdGenerator _nodeIdGenerator;

  OopExpressionParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  ThisExpressionNode parseThis(TokenStream stream) {
    final token = stream.advance();
    return ThisExpressionNode(id: _nextId(), span: token.span);
  }

  SuperExpressionNode parseSuper(TokenStream stream) {
    final token = stream.advance();
    return SuperExpressionNode(id: _nextId(), span: token.span);
  }

  InstantiationExpressionNode? parseInstantiation(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final newToken = stream.advance();
    if (!stream.check(TokenType.identifier)) {
      _reportExpectedClassName(stream, diagnostics);
      return null;
    }

    final nameToken = stream.advance();
    if (!stream.match(TokenType.leftParenthesis)) {
      return _handleMissingParentheses(
        stream,
        diagnostics,
        newToken,
        nameToken,
      );
    }

    final arguments =
        _parseInstantiationArguments(stream, diagnostics, parseExpr);
    return InstantiationExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(newToken.span),
      className: nameToken.lexeme,
      classNameSpan: nameToken.span,
      arguments: arguments,
    );
  }

  InstantiationExpressionNode _handleMissingParentheses(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Token newToken,
    Token nameToken,
  ) {
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.missingInstantiationParentheses,
        severity: Severity.error,
        span: nameToken.span,
      ),
    );
    return InstantiationExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(newToken.span, nameToken.span),
      className: nameToken.lexeme,
      classNameSpan: nameToken.span,
      arguments: const [],
    );
  }

  void _reportExpectedClassName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.expectedClassNameInInstantiation,
        severity: Severity.error,
        span: stream.peek().span,
      ),
    );
  }

  List<ExpressionNode> _parseInstantiationArguments(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final arguments = <ExpressionNode>[];
    if (!stream.match(TokenType.rightParenthesis)) {
      _parseArgumentList(stream, diagnostics, arguments, parseExpr);
      if (!stream.match(TokenType.rightParenthesis)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.unclosedParenthesis,
            severity: Severity.error,
            span: stream.peek().span,
          ),
        );
      }
    }
    return arguments;
  }

  ExpressionNode parseMemberAccessOrCall(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode target,
    ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  ) {
    final dotToken = stream.advance();
    if (!stream.check(TokenType.identifier) &&
        !stream.check(TokenType.constructor)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedMemberNameAfterDot,
          severity: Severity.error,
          span: dotToken.span,
        ),
      );
      return target;
    }

    final memberToken = stream.advance();
    if (stream.match(TokenType.leftParenthesis)) {
      return _parseMethodCallAfterMember(
        stream,
        diagnostics,
        target,
        memberToken,
        parseExpr: parseExpr,
      );
    }

    return MemberAccessExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(target.span, memberToken.span),
      target: target,
      memberName: memberToken.lexeme,
      memberSpan: memberToken.span,
    );
  }

  MethodCallExpressionNode _parseMethodCallAfterMember(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionNode target,
    Token memberToken, {
    required ExpressionNode? Function(TokenStream, List<Diagnostic>) parseExpr,
  }) {
    final arguments = <ExpressionNode>[];
    if (!stream.match(TokenType.rightParenthesis)) {
      _parseArgumentList(stream, diagnostics, arguments, parseExpr);
      if (!stream.match(TokenType.rightParenthesis)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.unclosedParenthesis,
            severity: Severity.error,
            span: stream.peek().span,
          ),
        );
      }
    }
    return MethodCallExpressionNode(
      id: _nextId(),
      span: stream.spanFrom(target.span),
      target: target,
      methodName: memberToken.lexeme,
      methodSpan: memberToken.span,
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
}
